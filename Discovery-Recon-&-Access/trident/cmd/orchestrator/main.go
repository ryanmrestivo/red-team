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
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/kelseyhightower/envconfig"
	log "github.com/sirupsen/logrus"

	"github.com/praetorian-inc/trident/pkg/auth/cloudflare"
	"github.com/praetorian-inc/trident/pkg/db"
	"github.com/praetorian-inc/trident/pkg/scheduler"
	"github.com/praetorian-inc/trident/pkg/server"
)

type specification struct {
	// trident server configuration options
	LogLevel           string `envconfig:"LOG_LEVEL" default:"INFO"`
	AdminListenerPort  int    `envconfig:"ADMIN_LISTENING_PORT" default:"9999"`
	DBConnectionString string `envconfig:"DB_CONNECTION_STRING" required:"true"`

	// cloudflare configuration options
	AuthDomain string `envconfig:"CF_AUTH_DOMAIN"`
	PolicyAUD  string `envconfig:"CF_AUDIENCE"`

	// pubsub configuration options
	ProjectID      string `envconfig:"PROJECT_ID" required:"true"`
	TopicID        string `envconfig:"TOPIC_ID" required:"true"`
	SubscriptionID string `envconfig:"SUBSCRIPTION_ID" required:"true"`

	// redis configuration options
	RedisURI      string `envconfig:"REDIS_URI" required:"true"`
	RedisPassword string `envconfig:"REDIS_PASSWORD"`
}

var spec specification

func init() {
	err := envconfig.Process("orchestrator", &spec)
	if err != nil {
		log.Fatal(err)
	}

	level, err := log.ParseLevel(spec.LogLevel)
	if err != nil {
		log.Fatal(err)
	}

	log.SetLevel(level)
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
		// https://tools.ietf.org/html/rfc3339
		TimestampFormat: time.RFC3339Nano,
	})
}

func main() {
	finish := make(chan bool)

	db, err := db.New(spec.DBConnectionString)
	if err != nil {
		log.WithFields(log.Fields{
			"connectionstring": spec.DBConnectionString,
		}).Fatal(err)
	}
	defer db.Close() // nolint:errcheck

	sch, err := scheduler.NewPubSubScheduler(scheduler.Options{
		Database:       db,
		ProjectID:      spec.ProjectID,
		TopicID:        spec.TopicID,
		SubscriptionID: spec.SubscriptionID,
		RedisURI:       spec.RedisURI,
		RedisPassword:  spec.RedisPassword,
	})
	if err != nil {
		log.Fatal(err)
	}

	s := &server.Server{
		DB:  db,
		Sch: sch,
	}

	log.WithFields(log.Fields{
		"spec": spec,
	}).Debug("server components successfully created")

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

	// Insert authenication middleware to verify JWTs on all requests
	r.Use(cloudflare.Verifier(spec.AuthDomain, spec.PolicyAUD))

	// routes
	r.Get("/healthz", s.HealthzHandler)
	r.Post("/campaign/status", s.StatusUpdateHandler)
	r.Post("/campaign", s.CampaignHandler)
	r.Post("/results", s.ResultsHandler)
	r.Get("/list", s.CampaignListHandler)
	r.Post("/describe", s.CampaignDescribeHandler)

	go func() {
		log.Printf("starting server on port %d", spec.AdminListenerPort)
		log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", spec.AdminListenerPort), r))
	}()

	go func() {
		log.Printf("starting scheduler task production to %s", spec.TopicID)
		sch.ProduceTasks()
	}()

	go func() {
		log.Printf("starting scheduler result consumption from %s", spec.SubscriptionID)
		log.Fatal(sch.ConsumeResults())
	}()

	<-finish
}
