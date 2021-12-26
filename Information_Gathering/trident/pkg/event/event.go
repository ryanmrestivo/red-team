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

package event

import (
	"time"
)

// AuthRequest defines a single authentication attempt task.
type AuthRequest struct {
	// CampaignID is used to track the results of the task
	CampaignID uint `json:"campaign_id"`

	// NotBefore will prevent execution until this time
	NotBefore time.Time `json:"not_before"`

	// NotAfter will prevent execution after this time
	NotAfter time.Time `json:"not_after"`

	// Username is the username at the identity provider
	Username string `json:"username"`

	// Password is the password to guess against the identity provider
	Password string `json:"password"`

	// Provider is the name of identity provider, used to look up the right nozzle
	Provider string `json:"provider"`

	// ProviderMetadata is any required configuration data for the provider
	ProviderMetadata map[string]string `json:"metadata"`
}

// AuthResponse represents the response to an authentication attempt.
type AuthResponse struct {
	// CampaignID is used to track the results of the task
	CampaignID uint `json:"campaign_id"`

	// IP is the originating IP of the credential guess
	IP string `json:"ip"`

	// Timestamp is the time that we made the request
	Timestamp time.Time `json:"timestamp"`

	// Username is the username at the identity provider
	Username string `json:"username"`

	// Password is the password to guess against the identity provider
	Password string `json:"password"`

	// Valid indicates the provided credential was valid
	Valid bool `json:"valid"`

	// Locked will be true iff the account is known to be locked
	Locked bool `json:"locked"`

	// MFA will be true iff the account is known to require MFA to log in
	MFA bool `json:"mfa"`

	// RateLimited indicates the provider has detected a large number of requests
	RateLimited bool `json:"rate_limited"`

	// Additional metadata from the auth provider (e.g. information about MFA)
	Metadata map[string]interface{} `json:"metadata"`
}

// ErrorResponse represents a failure in task processing. This response should
// be accompanied by a non-200 HTTP response code (e.g. HTTP 500).
type ErrorResponse struct {
	// ErrorMsg is the result of error.Error()
	ErrorMsg string `json:"error"`
}
