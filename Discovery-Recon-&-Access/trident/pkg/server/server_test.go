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

package server

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/praetorian-inc/trident/pkg/db"
)

type mockDB struct{}

func (m *mockDB) IsCampaignCancelled(campaignID uint) (bool, error) {
	//For now, always return false, but maybe we can make this return true for odd campaignIDs
	return false, nil
}

func (m *mockDB) InsertCampaign(c *db.Campaign) error {
	return nil
}

func (m *mockDB) UpdateCampaign(c *db.Campaign) error {
	return nil
}

func (m *mockDB) UpdateCampaignStatus(campaignID uint, status db.CampaignStatus) error {
	return nil
}

func (m *mockDB) SelectResults(q db.Query) ([]db.Result, error) {
	var results []db.Result

	dec := json.NewDecoder(strings.NewReader(`[
  {
    "id": 18,
    "created_at": "2020-08-28T14:02:34.844333414Z",
    "updated_at": "2020-08-28T14:02:34.844333414Z",
    "deleted_at": null,
    "not_before": "2020-08-28T00:00:00Z",
    "not_after": "2020-08-29T00:00:00Z",
    "schedule_interval": 500000000,
    "users": [
      "alice@example.org"
    ],
    "passwords": [
      "Password0",
      "Password1",
      "Password1!"
    ],
    "provider": "okta",
    "provider_metadata": {
      "subdomain": "example"
    },
    "results": null
  }
]`))

	err := dec.Decode(&results)
	if err != nil {
		return nil, err
	}

	return results, nil
}

func (m *mockDB) InsertResult(r *db.Result) error {

	return nil
}

func (m *mockDB) ListCampaign() ([]db.Campaign, error) {
	return []db.Campaign{
		{Provider: "okta", ProviderMetadata: json.RawMessage(`{"subdomain": "example"}`)},
		{Provider: "adfs", ProviderMetadata: json.RawMessage(`{"domain": "adfs.example.com"}`)},
	}, nil
}

func (m *mockDB) DescribeCampaign(query db.Query) (db.Campaign, error) {
	return db.Campaign{
		Provider:         "okta",
		ProviderMetadata: json.RawMessage(`{"subdomain":"example"}`),
	}, nil

}

func (m *mockDB) Close() error {
	return nil
}

type mockScheduler struct{}

func (m *mockScheduler) Schedule(c db.Campaign) error {
	return nil
}

func (m *mockScheduler) ProduceTasks() {
}

func (m *mockScheduler) ConsumeResults() error {
	return nil
}

func initServer() Server {
	return Server{
		DB:  &mockDB{},
		Sch: &mockScheduler{},
	}
}

func TestHealthzHandler(t *testing.T) {
	s := initServer()

	req, err := http.NewRequest("GET", "/healthz", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(s.HealthzHandler)

	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}
}

func TestCancelHandler(t *testing.T) {
	s := initServer()

	q := map[string]interface{}{
		"Status": db.CampaignStatusCancelled,
		"ID":     10,
	}

	buf := new(bytes.Buffer)
	err := json.NewEncoder(buf).Encode(q)
	if err != nil {
		t.Fatal(err)
	}

	req, err := http.NewRequest("POST", "/campaign/status", buf)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(s.StatusUpdateHandler)

	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}
}

func TestCampaignHandler(t *testing.T) {
	s := initServer()

	requestBody, err := json.Marshal(map[string]interface{}{
		"not_before":        "2020-08-28T00:00:00Z",
		"not_after":         "2020-08-29T00:00:00Z",
		"schedule_interval": 500000000,
		"users":             []string{"anthony.weems+lockout@praetorian.com"},
		"passwords":         []string{"Password0", "Password1", "Password1!"},
		"provider":          "okta",
		"provider_metadata": map[string]interface{}{
			"subdomain": "dev-634850",
		},
	})

	if err != nil {
		t.Fatal(err)
	}

	req, err := http.NewRequest("POST", "/campaign", bytes.NewBuffer(requestBody))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(s.CampaignHandler)

	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}
}

func TestResultsHandler(t *testing.T) {
	s := initServer()
	requestBody, err := json.Marshal(map[string]interface{}{
		"ReturnedFields": []string{"*"},
		"Filter": map[string]interface{}{
			"valid": true,
		},
	})
	if err != nil {
		t.Fatal(err)
	}

	req, err := http.NewRequest("POST", "/results", bytes.NewBuffer(requestBody))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(s.ResultsHandler)

	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}
}
