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

package adfs

import (
	"math/rand"
	"os"
	"testing"
	"time"

	"github.com/praetorian-inc/trident/pkg/nozzle"
)

func TestMain(m *testing.M) {
	rand.Seed(time.Now().UTC().UnixNano())
	v := m.Run()
	os.Exit(v)
}

func TestNozzle(t *testing.T) {
	_, err := nozzle.Open("adfs", map[string]string{
		"domain": "adfs.example.com",
	})
	if err != nil {
		t.Fatalf("unable to open nozzle: %s", err)
	}

	_, err = nozzle.Open("adfs", map[string]string{
		"domain":   "adfs.example.com",
		"strategy": "ntlm",
	})
	if err != nil {
		t.Fatalf("unable to open nozzle: %s", err)
	}

	_, err = nozzle.Open("adfs", map[string]string{
		"domain":   "adfs.example.com",
		"strategy": "usernamemixed",
	})
	if err != nil {
		t.Fatalf("unable to open nozzle: %s", err)
	}
}
