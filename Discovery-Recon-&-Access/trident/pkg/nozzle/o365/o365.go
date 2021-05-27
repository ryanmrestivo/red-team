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

package o365

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
	"strings"
	"time"

	"golang.org/x/time/rate"

	"github.com/praetorian-inc/trident/pkg/event"
	"github.com/praetorian-inc/trident/pkg/nozzle"
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
	nozzle.Register("o365", Driver{})
}

// New is used to create an o365 nozzle and accepts the following configuration
// options:
//
// domain
//
// The domain to send oauth requests to. This defaults to login.microsoft.com and
// is unlikely to require configuration.
func (Driver) New(opts map[string]string) (nozzle.Nozzle, error) {
	domain, ok := opts["domain"]
	if !ok {
		// domain not specified, using login.microsoft.com as default domain
		domain = "login.microsoft.com"
	}

	return &Nozzle{
		Domain:    domain,
		UserAgent: FrozenUserAgent,
	}, nil
}

// Nozzle implements the nozzle.Nozzle interface for o365.
type Nozzle struct {
	// Domain is the O365 domain
	// "login.microsoft.com" for example
	Domain string

	// UserAgent will override the Go-http-client user-agent in requests
	UserAgent string
}

// struct for error response from o365
type o365Error struct {
	Error             string  `json:"error"`
	ErrorDescription  string  `json:"error_description"`
	ErrorCodes        []int32 `json:"error_codes"`
	Timestamp         string  `json:"timestamp"`
	TraceID           string  `json:"trace_id"`
	CorrelationID     string  `json:"correlation_id"`
	ErrorURI          string  `json:"error_uri"`  // string might not be the best type for this
	Suberror          string  `json:",omitempty"` // from 401 response
	PasswordChangeURL string  `json:",omitempty"` // from 401 response
}

var (
	oauth2TokenURL  = "https://%s/common/oauth2/token" // nolint:gosec
	oauth2TokenBody = "grant_type=password" +
		"&resource=https://graph.windows.net" +
		"&client_id=1b730954-1685-4b74-9bfd-dac224a7b894" +
		"&lient_info=1" +
		"&username=%s" +
		"&password=%s" +
		"&scope=openid"
)

func (n *Nozzle) oauth2TokenLogin(username, password string) (*event.AuthResponse, error) {
	url := fmt.Sprintf(oauth2TokenURL, n.Domain)
	body := fmt.Sprintf(oauth2TokenBody, username, password)

	req, _ := http.NewRequest("POST", url, strings.NewReader(body))
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("User-Agent", n.UserAgent)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() // nolint:errcheck

	switch resp.StatusCode {
	// Success: from docs, it seems that 200 always indicates a successful auth attempt
	case 200:
		return &event.AuthResponse{
			Valid: true,
		}, nil
	// a 400 does not necessarily indicate a failure, we need to check
	// the response body to be sure
	case 400, 401:
		var res o365Error
		err = json.NewDecoder(resp.Body).Decode(&res)
		if err != nil {
			return nil, err
		}
		// defaults for AuthResponse
		valid := false
		mfa := false
		locked := false
		// extract AADST code supplied in error_description
		re := regexp.MustCompile("(AADSTS.*?):")
		matches := re.FindStringSubmatch(res.ErrorDescription)
		if len(matches) == 0 {
			return nil, fmt.Errorf("unhandled error description: %s", res.ErrorDescription)
		}
		code := strings.TrimRight(matches[1], ":")
		// switching on the AADSTS code
		// https://docs.microsoft.com/en-us/azure/active-directory/develop/reference-aadsts-error-codes
		switch code {
		case "AADSTS50128":
			// Invalid domain name - No tenant-identifying information found in either the
			// request or implied by any provided credentials.
			return nil, fmt.Errorf("invalid domain name from o365 nozzle")
		case "AADSTS50126":
			// InvalidUserNameOrPassword - Error validating credentials due to
			// invalid username or password.
			// keep default
		case "AADSTS50079":
			// UserStrongAuthEnrollmentRequired - Due to a configuration change made
			// by the administrator, or because the user moved
			// to a new location, the user is required to use multi-factor authentication.
			mfa = true
			valid = true
		case "AADSTS50076":
			// UserStrongAuthClientAuthNRequired - Due to a
			// configuration change made by the admin, or because you moved to a new location,
			// the user must use multi-factor authentication to access the resource. Retry with a
			// new authorize request for the resource.
			mfa = true
			valid = true
		case "AADSTS50059":
			// MissingTenantRealmAndNoUserInformationProvided - Tenant-identifying information was not found
			// in either the request or implied by any provided credentials. The user can contact
			// the tenant admin to help resolve the issue.
			return nil, fmt.Errorf("tenant identifying info was not found")
		case "AADSTS50057":
			// UserDisabled - The user account is disabled. The account has been disabled by an administrator.
			locked = true
		case "AADSTS50055":
			// InvalidPasswordExpiredPassword - The password is expired.
		case "AADSTS50053":
			// IdsLocked - The account is locked because the user tried to sign in too many times
			// with an incorrect user ID or password.
			locked = true
		case "AADSTS50034":
			// UserAccountNotFound - To sign into this application, the account must be added to the directory.
		}
		return &event.AuthResponse{
			Valid:  valid,
			Locked: locked,
			MFA:    mfa,
			Metadata: map[string]interface{}{
				"o365Error": res,
			},
		}, nil
	}

	return nil, fmt.Errorf("unhandled status code from o365 oauth2 token login: %d", resp.StatusCode)
}

// Login fulfils the nozzle.Nozzle interface and performs an authentication
// requests against o365. This function supports rate limiting and parses valid,
// invalid, and locked out responses.
func (n *Nozzle) Login(username, password string) (*event.AuthResponse, error) {
	ctx := context.Background()
	err := RateLimiter.Wait(ctx)
	if err != nil {
		return nil, err
	}

	return n.oauth2TokenLogin(username, password)
}
