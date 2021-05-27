// Copyright 2020 Praetorian Security, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"sync"

	log "github.com/sirupsen/logrus"

	"github.com/praetorian-inc/trident/pkg/nozzle"

	_ "github.com/praetorian-inc/trident/pkg/nozzle/adfs"
	_ "github.com/praetorian-inc/trident/pkg/nozzle/o365"
	_ "github.com/praetorian-inc/trident/pkg/nozzle/okta"
)

var (
	flagProvider     string
	flagProviderMeta string
	flagUsernames    string
	flagPasswords    string
)

func main() {
	flag.StringVar(&flagProvider, "provider", "okta", "authentication provider")
	flag.StringVar(&flagProviderMeta, "metadata", "{}", "configuration data for auth provider")
	flag.StringVar(&flagUsernames, "usernames", "-", "path to username list (or '-' for stdin)")
	flag.StringVar(&flagPasswords, "passwords", "passwords.txt", "path to password list")
	flag.Parse()

	var metadata map[string]string
	err := json.Unmarshal([]byte(flagProviderMeta), &metadata)
	if err != nil {
		log.Fatalf("error parsing provider metadata: %s", err)
	}

	if flagUsernames == "-" {
		flagUsernames = "/dev/stdin"
	}

	usernames, err := os.Open(flagUsernames) // nolint:gosec
	if err != nil {
		log.Fatalf("error reading usernames: %s", err)
	}
	defer usernames.Close() // nolint:errcheck,gosec

	content, err := ioutil.ReadFile(flagPasswords) // nolint:gosec
	if err != nil {
		log.Fatalf("error reading passwords: %s", err)
	}
	passwords := strings.Split(string(content), "\n")

	noz, err := nozzle.Open(flagProvider, metadata)
	if err != nil {
		log.Fatalf("error opening nozzle: %s", err)
	}

	var wg sync.WaitGroup

	scanner := bufio.NewScanner(usernames)
	for scanner.Scan() {
		username := scanner.Text()
		if username == "" {
			continue
		}

		for _, password := range passwords {
			if password == "" {
				continue
			}

			wg.Add(1)
			go func(username, password string) {
				res, err := noz.Login(username, password)
				if err != nil {
					log.Fatalf("error logging in: %s", err)
				}

				if res.Valid {
					fmt.Printf("%s:%s\n", username, password)
				} else {
					log.Infof("invalid credential (%s, %s)", username, password)
				}
				wg.Done()
			}(username, password)
		}

	}

	if err := scanner.Err(); err != nil {
		log.Fatalf("scanner error: %s", err)
	}

	wg.Wait()
}
