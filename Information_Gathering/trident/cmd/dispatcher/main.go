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
	"context"
	"time"

	"github.com/kelseyhightower/envconfig"
	log "github.com/sirupsen/logrus"

	"github.com/praetorian-inc/trident/pkg/dispatch"

	_ "github.com/praetorian-inc/trident/pkg/dispatch/clients/webhook"
)

type specification struct {
	LogLevel string `envconfig:"LOG_LEVEL" default:"INFO"`

	ProjectID      string `envconfig:"PROJECT_ID" required:"true"`
	ResultTopicID  string `envconfig:"RESULT_TOPIC_ID" required:"true"`
	SubscriptionID string `envconfig:"SUBSCRIPTION_ID" required:"true"`

	WorkerName   string                 `envconfig:"WORKER_NAME" required:"true"`
	WorkerConfig dispatch.WorkerOptions `envconfig:"WORKER_CONFIG" required:"true"`
}

var spec specification

func init() {
	err := envconfig.Process("dispatcher", &spec)
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

func main() {
	ctx := context.Background()

	worker, err := dispatch.Open(spec.WorkerName, spec.WorkerConfig)
	if err != nil {
		log.Fatal(err)
	}
	dis, err := dispatch.NewDispatcher(ctx, dispatch.Options{
		ProjectID:      spec.ProjectID,
		SubscriptionID: spec.SubscriptionID,
		ResultTopicID:  spec.ResultTopicID,
	}, worker)
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("starting dispatcher for subscription %s", spec.SubscriptionID)
	log.Fatal(dis.Listen(ctx))
}
