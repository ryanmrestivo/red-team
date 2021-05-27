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

package db

import (
	"encoding/json"
	"time"

	"github.com/lib/pq"
)

// Model is the base type that contains information about the DB record being stored.
type Model struct {
	ID        uint       `json:"id" gorm:"primary_key"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at"`
}

// The CampaignStatus enum indicates the current state of a Campaign
type CampaignStatus string

const (
	// CampaignStatusCancelled is the value of the Status column if the campaign is Cancelled
	// unlike a Halted campaign, a cancelled campaign must be completely restarted, it cannot be resumed
	CampaignStatusCancelled CampaignStatus = "Cancelled"
	// CampaignStatusActive is the value of the Status column if the campaign is not Cancelled
	// for campaigns added before this change, they may also have an empty Status field for now
	CampaignStatusActive = "Active"
	// CampaignStatusPaused is the value of the Status column if the campaign is Paused.
	// Paused campaigns can be resumed, whereas cancelling is permanent
	CampaignStatusPaused = "Paused"
)

// Campaign stores the metadata associated with an entire password spraying campaign
type Campaign struct {
	// inherit the base model's fields
	Model

	// a campaign should not make requests before this time
	NotBefore time.Time `json:"not_before"`

	// a campaign should not make requests after this time
	NotAfter time.Time `json:"not_after"`

	// a campaign should make requests with this interval in between them
	ScheduleInterval time.Duration `json:"schedule_interval"`

	// current status of the campaign, used to pause/cancel/resume without deletion
	Status CampaignStatus `json:"status"`

	// the slice of usernames to guess in this campaign
	Users pq.StringArray `json:"users" gorm:"type:varchar(255)[]"`

	// passwords to try during this campaign
	Passwords pq.StringArray `json:"passwords" gorm:"type:varchar(255)[]"`

	// the authentication portal this campaign is targeting
	Provider string `json:"provider"`

	// any extra metadata that the auth provider will need to make
	// successful requests to the portal
	ProviderMetadata json.RawMessage `json:"provider_metadata"`

	// the results of the campaign
	Results []Result `json:"results"`
}

// Result carries metadata about an individual result from the password spraying
// campaign
type Result struct {
	// inherit the base model's fields
	Model

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

	// MFA will be true iff the account requires MFA to log in
	MFA bool `json:"mfa"`

	// RateLimited indicates the provider has detected a large number of requests
	RateLimited bool `json:"rate_limited"`

	// Additional metadata from the auth provider (e.g. information about MFA)
	Metadata json.RawMessage `json:"metadata"`
}

// Task carries metadata about a single task in the password spraying campaign
type Task struct {
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
	ProviderMetadata json.RawMessage `json:"metadata"`
}

// MarshalBinary task marshalling
func (t *Task) MarshalBinary() ([]byte, error) {
	return json.Marshal(t)
}

// UnmarshalBinary task unmarshalling
func (t *Task) UnmarshalBinary(data []byte) error {
	return json.Unmarshal(data, &t)
}
