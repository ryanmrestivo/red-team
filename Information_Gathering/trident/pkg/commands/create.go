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

package commands

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/praetorian-inc/trident/pkg/db"
	"net/http"
	"os"
	"strings"
	"time"

	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	// path to file containing usernames to test(newline separated)
	flagUsernameFile string

	// path to file containing passwords to test(newline separated)
	flagPasswordFile string

	// string with RFC3339Nano date format, default is time.Now()
	flagNotBefore string

	// duration describing the window for the campaign to take place in,
	// used to compute NotAfter
	flagActiveWindow time.Duration

	// duration used to throttle individual requests by this much
	flagScheduleInterval time.Duration

	// authentication provider to select for target, provider metadata is
	// read from the config file
	flagProvider string
)

const (
	campaignSummary = `
[Campaign Summary]
Not Before: %s
Not After: %s
Interval: %s
Username count: %d
Password count: %d
Provider: %s
Metadata: %v

`
)

var campaignCreateCmd = &cobra.Command{
	Use:   "create",
	Short: "campaign management subcommand",
	Long:  `can be used to create and examine existing password spraying campaigns`,
	Run: func(cmd *cobra.Command, args []string) {
		campaignCreate(cmd, args)
	},
}

func init() {
	defaultNotBefore := time.Now().Format(time.RFC3339Nano)

	// required arguments

	campaignCreateCmd.Flags().StringVarP(&flagUsernameFile, "userfile", "u", "",
		"file of usernames (newline separated)")
	err := campaignCreateCmd.MarkFlagRequired("userfile")
	if err != nil {
		log.Fatalf("issue during argument parsing: %s", err)

	}

	campaignCreateCmd.Flags().StringVarP(&flagPasswordFile, "passfile", "p", "",
		"file of passwords (newline separated)")
	err = campaignCreateCmd.MarkFlagRequired("passfile")
	if err != nil {
		log.Fatalf("issue during argument parsing: %s", err)

	}

	// optional arguments

	// default: time.Now()
	campaignCreateCmd.Flags().StringVarP(&flagNotBefore, "notbefore", "b", defaultNotBefore,
		"requests will not start before this time")

	// default: 4 weeks = 672 hours, lol
	campaignCreateCmd.Flags().DurationVarP(&flagActiveWindow, "window", "w", 672*time.Hour,
		"a duration that this campaign will be active (ex: 4w)")

	// default: 1 second
	campaignCreateCmd.Flags().DurationVarP(&flagScheduleInterval, "interval", "i", time.Second,
		"requests will happen with this interval between them")

	// default: okta
	campaignCreateCmd.Flags().StringVarP(&flagProvider, "auth-provider", "a", "okta",
		"this is the authentication platform you are attacking")

	campaignCmd.AddCommand(campaignCreateCmd)
}

// readLines reads a whole file into memory
// and returns a slice of its lines.
func readLines(path string) ([]string, error) {
	file, err := os.Open(path) //nolint:gosec
	if err != nil {
		return nil, err
	}
	defer file.Close() // nolint:errcheck,gosec

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines, scanner.Err()
}

func confirm(s string) bool {
	fmt.Printf("%s [y/N]: ", s)

	reader := bufio.NewReader(os.Stdin)
	r, err := reader.ReadString('\n')
	if err != nil {
		log.Fatal(err)
	}

	r = strings.ToLower(strings.TrimSpace(r))
	if r == "y" || r == "yes" {
		return true
	}
	return false
}

func campaignCreate(cmd *cobra.Command, args []string) {
	orchestrator := viper.GetString("orchestrator-url")
	providers := viper.GetStringMap("providers")

	users, err := readLines(flagUsernameFile)
	if err != nil {
		log.Fatalf("error reading lines from user file: %s", err)
	}

	passwords, err := readLines(flagPasswordFile)
	if err != nil {
		log.Fatalf("error reading lines from password file: %s", err)
	}

	parsedNotBefore, err := time.Parse(time.RFC3339Nano, flagNotBefore)
	if err != nil {
		log.Fatalf("error parsing notBefore time: %s", err)
	}

	// duration math. NotAfter = NotBefore + ActiveWindow
	parsedNotAfter := parsedNotBefore.Add(flagActiveWindow)

	requestBody, err := json.Marshal(map[string]interface{}{
		"not_before":        parsedNotBefore,
		"not_after":         parsedNotAfter,
		"status":            db.CampaignStatusActive,
		"schedule_interval": flagScheduleInterval,
		"users":             users,
		"passwords":         passwords,
		"provider":          flagProvider,
		"provider_metadata": providers[flagProvider],
	})
	if err != nil {
		log.Fatalf("error during JSON marshalling for request body: %s", err)
	}

	// print summary of campaign and prompt user to accept
	fmt.Printf(campaignSummary, parsedNotBefore, parsedNotAfter, flagScheduleInterval,
		len(users), len(passwords), flagProvider, providers[flagProvider])
	if !confirm("Send campaign?") {
		log.Printf("not sending campaign")
		return
	}

	req, err := http.NewRequest("POST", orchestrator+"/campaign", bytes.NewBuffer(requestBody))
	if err != nil {
		log.Fatalf("error during request creation: %s", err)
	}

	// add the authentication token to the request
	err = authenticator.Auth(req)
	if err != nil {
		log.Fatalf("error during authentication: %s", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Fatalf("error sending request: %s", err)
	}
	defer resp.Body.Close() // nolint:errcheck

	log.Debug(resp)
	log.Info("successfully created campaign")
}
