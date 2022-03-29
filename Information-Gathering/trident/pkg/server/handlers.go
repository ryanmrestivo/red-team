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
	"encoding/json"
	"errors"
	"net/http"

	log "github.com/sirupsen/logrus"

	"github.com/praetorian-inc/trident/pkg/db"
	"github.com/praetorian-inc/trident/pkg/parse"
	"github.com/praetorian-inc/trident/pkg/scheduler"
)

// Server carries context for the http handlers to work from. it keeps track of
// the current server's database connection pool and scheduler.
type Server struct {
	DB  db.Datastore
	Sch scheduler.Scheduler
}

// HealthzHandler is for k8s health checking, this always returns 200
func (s *Server) HealthzHandler(w http.ResponseWriter, r *http.Request) {}

// CampaignHandler receives data from the user about the desired campaign
// configuration. it then inserts the associated metadata into the db and
// schedules the campaign.
func (s *Server) CampaignHandler(w http.ResponseWriter, r *http.Request) {
	log.Info("creating campaign")
	var c db.Campaign

	err := parse.DecodeJSONBody(w, r, &c)
	if err != nil {
		var mr *parse.MalformedRequest
		if errors.As(err, &mr) {
			http.Error(w, mr.Msg, mr.Status)
		} else {
			log.Errorf("unknown error decoding json: %s", err)
			http.Error(w, http.StatusText(500), 500)
		}
		return
	}

	err = s.DB.InsertCampaign(&c)
	if err != nil {
		log.WithFields(log.Fields{
			"campaign": c,
		}).Errorf("error inserting campaign: %s", err)
		return
	}

	go s.Sch.Schedule(c) // nolint:errcheck

	w.Header().Add("Content-Type", "application/json")
	err = json.NewEncoder(w).Encode(&c)
	if err != nil {
		log.WithFields(log.Fields{
			"campaign": c,
		}).Errorf("error encoding campaign for return: %s", err)
		return
	}
}

// ResultsHandler takes a user defined database query (returned fields + filter)
// and applies it, returning the results in JSON
func (s *Server) ResultsHandler(w http.ResponseWriter, r *http.Request) {
	var q db.Query

	err := parse.DecodeJSONBody(w, r, &q)
	if err != nil {
		var mr *parse.MalformedRequest
		if errors.As(err, &mr) {
			http.Error(w, mr.Msg, mr.Status)
		} else {
			log.Errorf("unknown error decoding json: %s", err)
			http.Error(w, http.StatusText(500), 500)
		}
		return
	}

	results, err := s.DB.SelectResults(q)
	if err != nil {
		log.Printf("error querying database: %s", err)
		http.Error(w, http.StatusText(500), 500)
	}

	err = json.NewEncoder(w).Encode(&results)
	if err != nil {
		log.WithFields(log.Fields{
			"results": results,
		}).Errorf("error encoding results: %s", err)
		return
	}
}

// CampaignListHandler accepts no parameters and returns the list of active campaigns
// via JSON
func (s *Server) CampaignListHandler(w http.ResponseWriter, r *http.Request) {
	var campaigns []db.Campaign

	campaigns, err := s.DB.ListCampaign()
	if err != nil {
		log.Printf("error querying database: %s", err)
		http.Error(w, http.StatusText(500), 500)
	}

	err = json.NewEncoder(w).Encode(&campaigns)
	if err != nil {
		log.WithFields(log.Fields{
			"results": campaigns,
		}).Errorf("error encoding results: %s", err)
		return
	}
}

// CampaignDescribeHandler takes a user-defined DB query with the campaignID, then
// returns the parameters of that campaign via JSON
func (s *Server) CampaignDescribeHandler(w http.ResponseWriter, r *http.Request) {
	var q db.Query
	var campaign db.Campaign

	err := parse.DecodeJSONBody(w, r, &q)
	if err != nil {
		var mr *parse.MalformedRequest
		if errors.As(err, &mr) {
			http.Error(w, mr.Msg, mr.Status)
		} else {
			log.Errorf("unknown error decoding json: %s", err)
			http.Error(w, http.StatusText(500), 500)
		}
		return
	}

	campaign, err = s.DB.DescribeCampaign(q)
	if err != nil {
		log.Printf("error querying database: %s", err)
		http.Error(w, http.StatusText(500), 500)
	}

	err = json.NewEncoder(w).Encode(&campaign)
	if err != nil {
		log.WithFields(log.Fields{
			"campaign": campaign,
		}).Errorf("error encoding campaign: %s", err)
		return
	}
}

// StatusUpdateHandler takes a campaignID from the user, then
// sets its status based on the post body content.
func (s *Server) StatusUpdateHandler(w http.ResponseWriter, r *http.Request) {
	type StatusUpdateHandler struct {
		ID     uint
		Status db.CampaignStatus
	}

	var postBody StatusUpdateHandler

	err := parse.DecodeJSONBody(w, r, &postBody)
	if err != nil {
		var mr *parse.MalformedRequest
		if errors.As(err, &mr) {
			http.Error(w, mr.Msg, mr.Status)
		} else {
			log.Errorf("unknown error decoding json: %s", err)
			http.Error(w, http.StatusText(500), 500)
		}
		return
	}

	err = s.DB.UpdateCampaignStatus(postBody.ID, postBody.Status)
	if err != nil {
		log.Printf("error updating database: %s", err)
		http.Error(w, http.StatusText(500), 500)
	}

	log.Infof("campaign id=%d status has been set to %s", postBody.ID, postBody.Status)
}
