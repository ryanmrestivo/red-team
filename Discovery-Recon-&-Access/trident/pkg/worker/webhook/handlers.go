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

package webhook

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	log "github.com/sirupsen/logrus"

	"github.com/praetorian-inc/trident/pkg/event"
	"github.com/praetorian-inc/trident/pkg/nozzle"
	"github.com/praetorian-inc/trident/pkg/util"
)

// Server implements an HTTP server handler for handling tasks.
type Server struct {
	ip string
}

// NewWebhookServer creates a new Server.
func NewWebhookServer() (*Server, error) {
	externalIP, err := util.ExternalIP()
	if err != nil {
		log.Fatal(err)
	}
	return &Server{
		ip: externalIP,
	}, nil
}

// HealthzHandler returns an HTTP 200 ok always.
func (s *Server) HealthzHandler(w http.ResponseWriter, r *http.Request) {}

func httperr(w http.ResponseWriter, err error) {
	res := event.ErrorResponse{ErrorMsg: err.Error()}
	w.WriteHeader(500)
	json.NewEncoder(w).Encode(&res) // nolint:errcheck,gosec
}

// EventHandler accepts an AuthRequest, executes the task using the nozzle
// interface and returns the AuthResponse via JSON.
func (s *Server) EventHandler(w http.ResponseWriter, r *http.Request) {
	var req event.AuthRequest

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		httperr(w, fmt.Errorf("error decoding body: %w", err))
		return
	}

	noz, err := nozzle.Open(req.Provider, req.ProviderMetadata)
	if err != nil {
		httperr(w, fmt.Errorf("error opening nozzle: %w", err))
		return
	}

	ts := time.Now()
	res, err := noz.Login(req.Username, req.Password)
	if err != nil {
		httperr(w, fmt.Errorf("error authenticating to %s provider: %w", req.Provider, err))
		return
	}

	// fill in generic AuthResult values
	res.CampaignID = req.CampaignID
	res.Username = req.Username
	res.Password = req.Password
	res.Timestamp = ts
	res.IP = s.ip

	json.NewEncoder(w).Encode(&res) // nolint:errcheck,gosec
}
