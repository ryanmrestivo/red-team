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

package main

import (
	"crypto/subtle"
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/kelseyhightower/envconfig"
	log "github.com/sirupsen/logrus"

	"github.com/praetorian-inc/trident/pkg/worker/webhook"

	_ "github.com/praetorian-inc/trident/pkg/nozzle/adfs"
	_ "github.com/praetorian-inc/trident/pkg/nozzle/o365"
	_ "github.com/praetorian-inc/trident/pkg/nozzle/okta"
)

type specification struct {
	LogLevel    string `envconfig:"LOG_LEVEL" default:"INFO"`
	Port        int    `envconfig:"PORT"`
	AccessToken []byte `envconfig:"ACCESS_TOKEN"`
}

var spec specification

func init() {
	err := envconfig.Process("worker", &spec)
	if err != nil {
		log.Fatal(err)
	}

	level, err := log.ParseLevel(spec.LogLevel)
	if err != nil {
		log.Fatal(err)
	}

	log.SetLevel(level)
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp:   true,
		TimestampFormat: time.RFC3339Nano,
	})
}

func tokenVerifier(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("X-Access-Token")
		if subtle.ConstantTimeCompare([]byte(token), spec.AccessToken) == 0 {
			http.Error(w, http.StatusText(403), 403)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	s, err := webhook.NewWebhookServer()
	if err != nil {
		log.Fatal(err)
	}

	r := chi.NewRouter()

	// A good base middleware stack
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	// Set a timeout value on the request context (ctx), that will signal
	// through ctx.Done() that the request has timed out and further
	// processing should be stopped.
	r.Use(middleware.Timeout(60 * time.Second))

	// Insert authenication middleware to verify access token on all requests
	r.Use(tokenVerifier)

	r.Get("/healthz", s.HealthzHandler)
	r.Post("/", s.EventHandler)

	log.Printf("starting server on port %d", spec.Port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", spec.Port), r))
}
