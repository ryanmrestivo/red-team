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
	"fmt"
	"log"
	"net/url"
	"strings"
	"time"

	"github.com/jinzhu/gorm"
	"github.com/lib/pq"
)

// Datastore is an interface that allows for the swap of backend database
// drivers to support other db platforms.
type Datastore interface {
	InsertCampaign(*Campaign) error
	UpdateCampaign(*Campaign) error
	SelectResults(Query) ([]Result, error)
	InsertResult(*Result) error
	ListCampaign() ([]Campaign, error)
	DescribeCampaign(Query) (Campaign, error)
	IsCampaignCancelled(uint) (bool, error)
	UpdateCampaignStatus(uint, CampaignStatus) error
	Close() error
}

// TridentDB implements the Datastore interface. it is backed by a gorm.DB type
type TridentDB struct {
	db *gorm.DB
}

// Query allows a user to specify a filter (json formatted) and a list of fields
// to be returned.
type Query struct {
	ReturnedFields []string
	Filter         map[string]interface{}
}

// ConnectionError is a custom error type to report issues connecting to the
// backend database
type ConnectionError struct {
	Msg string
}

// Error allows ConnectionError to implement the error interface
func (ce *ConnectionError) Error() string {
	return fmt.Sprintf("connection error: %s", ce.Msg)
}

// New returns a pointer to a newly constructed TridentDB. the connection string
// format should be parseable by url.Parse.
//
// ex: postgres://username:password@instance/database?key=value
//
func New(connectionString string) (*TridentDB, error) {
	u, err := url.Parse(connectionString)
	if err != nil {
		log.Fatal(err)
	}

	driver := u.Scheme
	instance := u.Host
	user := u.User.Username()
	password, set := u.User.Password()
	if !set {
		return nil, &ConnectionError{Msg: "no password was provided to authenticate to the database."}
	}

	database := strings.Trim(u.Path, "/")

	parsedConnectionString := fmt.Sprintf("host=%s user=%s dbname=%s password=%s", instance, user, database, password)
	for k, v := range u.Query() {
		parsedConnectionString += fmt.Sprintf(" %s=%s", k, v[0])
	}

	var s TridentDB

	s.db, err = gorm.Open(driver, parsedConnectionString)
	if err != nil {
		msg := fmt.Sprintf("gorm encountered an error %s", err)
		return nil, &ConnectionError{Msg: msg}
	}

	s.db.AutoMigrate(&Campaign{})
	s.db.AutoMigrate(&Result{})

	return &s, nil
}

// Close closes the underlying gorm db instance
func (t *TridentDB) Close() error {
	err := t.db.Close()
	return err
}

// InsertCampaign is a required function by the Datastore interface. it is a
// thin wrapper around the Gorm create method, this is largely to help with
// database mocking for tests (and for help with multiple drivers in the
// future).
func (t *TridentDB) InsertCampaign(campaign *Campaign) error {
	return t.db.Create(campaign).Error
}

// UpdateCampaign is a required function by the Datastore interface. it is a
// thin wrapper around the Gorm save method, this is largely to help with
// database mocking for tests (and for help with multiple drivers in the
// future).
func (t *TridentDB) UpdateCampaign(campaign *Campaign) error {
	return t.db.Save(campaign).Error
}

// UpdateCampaignStatus sets the Status property for the provided campaign ID.
func (t *TridentDB) UpdateCampaignStatus(campaignID uint, status CampaignStatus) error {
	campaign := Campaign{
		Model: Model{ID: campaignID},
	}

	return t.db.Model(&campaign).Update("Status", status).Error
}

// GetCampaignStatus returns the CampaignStatus mapped to a specific campaignID
func (t *TridentDB) GetCampaignStatus(campaignID uint) (CampaignStatus, error) {
	var retrievedCampaign Campaign

	err := t.db.Where("id = ?", campaignID).Select([]string{"id", "status"}).First(&retrievedCampaign).Error
	if err != nil {
		return "", err
	} else if retrievedCampaign.Status == "" {
		// Default value for campaigns with uninitialized Status (legacy handling)
		return CampaignStatusActive, nil
	}
	return retrievedCampaign.Status, nil
}

// SelectResults is a required function by the Datastore interface. it uses a
// query struct which contains both a database filter and a list of fields to
// return.
func (t *TridentDB) SelectResults(query Query) ([]Result, error) {
	var results []Result

	err := t.db.Select(query.ReturnedFields).
		Where(query.Filter).
		Order("timestamp DESC").
		Find(&results).
		Error
	if err != nil {
		return nil, err
	}

	return results, nil
}

// InsertResult is a required function by the Datastore interface. it is a
// thin wrapper around the Gorm create method, this is largely to help with
// database mocking for tests (and for help with multiple drivers in the
// future).
func (t *TridentDB) InsertResult(res *Result) error {
	return t.db.Create(res).Error
}

const (
	// StreamingInsertTimeout is the amount of time to batch transactions
	// for
	StreamingInsertTimeout = 3 * time.Second

	// StreamingInsertMax is the amount of transactions to batch at a time
	StreamingInsertMax = 5000
)

// StreamingInsertResults is used to batch writes to the database for performance reasons.
func (t *TridentDB) StreamingInsertResults() chan *Result {
	results := make(chan *Result, StreamingInsertMax)
	go func() {
		for {
			txn, err := t.db.DB().Begin()
			if err != nil {
				log.Fatal(err)
			}

			stmt, err := txn.Prepare(pq.CopyIn("results",
				"campaign_id", "ip", "timestamp", "username", "password",
				"valid", "locked", "mfa", "rate_limited", "metadata",
			))
			if err != nil {
				log.Fatal(err)
			}

			execres := func(r *Result) {
				_, err = stmt.Exec(
					r.CampaignID, r.IP, r.Timestamp, r.Username, r.Password,
					r.Valid, r.Locked, r.MFA, r.RateLimited, r.Metadata,
				)
				if err != nil {
					log.Printf("error in streaming exec: %s", err)
					results <- r
				}
			}

			// 1st iter: block until we read a single result
			// Nth iter: attempt to Exec a result, but allow timeout
			//  At most, we will write StreamingInsertMax records at a time
			//  within StreamingInsertTimeout seconds
			execres(<-results)

			count := 1
			timer := time.NewTimer(StreamingInsertTimeout)
			for {
				select {
				case r := <-results:
					execres(r)

					count++
					if count > StreamingInsertMax {
						goto commit
					}
				case <-timer.C:
					goto commit
				}

				if !timer.Stop() {
					<-timer.C
				}
				timer.Reset(StreamingInsertTimeout)
			}

		commit:
			_, err = stmt.Exec()
			if err != nil {
				log.Fatal(err)
			}

			err = stmt.Close()
			if err != nil {
				log.Fatal(err)
			}

			err = txn.Commit()
			if err != nil {
				log.Fatal(err)
			}
		}
	}()
	return results
}

// ListCampaign queries metadata from the list of all campaigns.
func (t *TridentDB) ListCampaign() ([]Campaign, error) {
	var campaigns []Campaign

	err := t.db.Select([]string{"id", "provider", "provider_metadata", "status", "created_at"}).
		Find(&campaigns).Error
	if err != nil {
		return nil, err
	}

	return campaigns, nil
}

// IsCampaignCancelled takes a campaign ID and returns true if the campaign status is CampaignStatusCancelled
func (t *TridentDB) IsCampaignCancelled(campaignID uint) (bool, error) {
	var count int64
	campaign := Campaign{
		Model: Model{ID: campaignID},
	}

	err := t.db.
		Model(&campaign).
		Where("status = ?", CampaignStatusCancelled).
		Count(&count).
		Error

	if err != nil {
		return false, err
	}

	return count > 0, nil
}

// DescribeCampaign queries all data about a specific campaign.
func (t *TridentDB) DescribeCampaign(query Query) (Campaign, error) {
	var campaign Campaign

	err := t.db.Where(query.Filter).Find(&campaign).Error
	if err != nil {
		return campaign, err
	}

	return campaign, nil
}
