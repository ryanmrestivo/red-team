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

package okta

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"golang.org/x/time/rate"

	"github.com/praetorian-inc/trident/pkg/event"
	"github.com/praetorian-inc/trident/pkg/nozzle"
	"github.com/praetorian-inc/trident/pkg/util"
)

const (
	// FrozenUserAgent is a static user agent that we use for all requests. This
	// value is based on the UA client hint work within browsers.
	// Additional details: https://bugs.chromium.org/p/chromium/issues/detail?id=955620
	FrozenUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" +
		"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3764.0 Safari/537.36"
)

var (
	// RateLimiter limits requests from the same worker to a maximum of 3/s
	RateLimiter = rate.NewLimiter(rate.Every(300*time.Millisecond), 1)
)

// Driver implements the nozzle.Driver interface.
type Driver struct{}

func init() {
	nozzle.Register("okta", Driver{})
}

// New is used to create an Okta nozzle and accepts the following configuration
// options:
//
// domain
//
// The subdomain of the Okta organization. If a user logs in at
// example.okta.com, the value of subdomain is "example".
func (Driver) New(opts map[string]string) (nozzle.Nozzle, error) {
	subdomain, ok := opts["subdomain"]
	if !ok {
		return nil, fmt.Errorf("okta nozzle requires 'subdomain' config parameter")
	}

	return &Nozzle{
		Subdomain: subdomain,
		UserAgent: FrozenUserAgent,
	}, nil
}

// Nozzle implements the nozzle.Nozzle interface for Okta.
type Nozzle struct {
	// Subdomain is the Okta subdomain
	Subdomain string

	// UserAgent will override the Go-http-client user-agent in requests
	UserAgent string
}

type oktaAuthResponse struct {
	Status   string                 `json:"status"`
	Factor   string                 `json:"factorResult"`
	Embedded map[string]interface{} `json:"_embedded"`
}

// Login fulfils the nozzle.Nozzle interface and performs an authentication
// requests against Okta. This function supports rate limiting and parses valid,
// invalid, and locked out responses.
func (n *Nozzle) Login(username, password string) (*event.AuthResponse, error) {
	ctx := context.Background()
	err := RateLimiter.Wait(ctx)
	if err != nil {
		return nil, err
	}

	url := fmt.Sprintf("https://%s.okta.com/api/v1/authn", n.Subdomain)
	err = util.ValidateURLSuffix(url, ".okta.com")
	if err != nil {
		return nil, err
	}

	data, _ := json.Marshal(map[string]string{
		"username": username,
		"password": password,
	})
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(data))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("User-Agent", n.UserAgent)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() // nolint:errcheck

	switch resp.StatusCode {
	case 200:
		var res oktaAuthResponse
		err = json.NewDecoder(resp.Body).Decode(&res)
		if err != nil {
			return nil, err
		}

		return &event.AuthResponse{
			Valid:    res.Status != "LOCKED_OUT",
			MFA:      res.Status == "MFA_REQUIRED",
			Locked:   res.Status == "LOCKED_OUT",
			Metadata: res.Embedded,
		}, nil
	case 401:
		return &event.AuthResponse{
			Valid: false,
		}, nil
	case 429:
		return &event.AuthResponse{
			RateLimited: true,
		}, nil
	}

	return nil, fmt.Errorf("unhandled status code from okta provider: %d", resp.StatusCode)
}
