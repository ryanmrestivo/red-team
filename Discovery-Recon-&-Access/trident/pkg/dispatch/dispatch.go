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

// Package dispatch defines an interface for all password spraying
// implementations For example, a webhook worker client will send tasks to via
// HTTP requests. Additionally, this package provides a registration mechanism
// similar to database/sql. Make sure to "blank import" each dispatch.
//
//  import (
//      "github.com/praetorian-inc/trident/pkg/dispatch"
//
//      _ "github.com/praetorian-inc/trident/pkg/dispatch/clients/webhook"
//  )
//
//  var req event.AuthRequest
//  // ...
//  worker, err := dispatch.Open("webhook", map[string]string{"url":"https://example.org"})
//  if err != nil {
//      // handle error
//  }
//  resp, err := worker.Submit(req)
//  // ...
//
// See https://golang.org/doc/effective_go.html#blank_import for more
// information on "blank imports".
package dispatch

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"cloud.google.com/go/pubsub"

	"github.com/praetorian-inc/trident/pkg/event"
)

// Dispatcher creates a data pipeline which accepts tasks, sends them to a
// worker, and publishes the result. This pipeline can be visualized as:
//  PubSub Subscription --> WorkerClient --> PubSub Topic
type Dispatcher struct {
	wc WorkerClient

	sub     *pubsub.Subscription
	resultc *pubsub.Topic
}

// Options is used to configure a Dispatcher
type Options struct {

	// ProjectID is the Google Cloud Platform project ID
	ProjectID string

	// SubscriptionID is the Pub/Sub subscription used by the dispatcher to
	// listen for incoming tasks.
	SubscriptionID string

	// ResultTopicID is the Pub/Sub topic ID used by the dispatcher to publish
	// results..
	ResultTopicID string
}

// NewDispatcher creates a dispatcher based on the provided options and worker.
func NewDispatcher(ctx context.Context, opts Options, wc WorkerClient) (*Dispatcher, error) {
	client, err := pubsub.NewClient(ctx, opts.ProjectID)
	if err != nil {
		return nil, err
	}

	sub := client.Subscription(opts.SubscriptionID)
	sub.ReceiveSettings.Synchronous = true
	sub.ReceiveSettings.MaxOutstandingMessages = 10

	return &Dispatcher{
		wc:      wc,
		sub:     sub,
		resultc: client.Topic(opts.ResultTopicID),
	}, nil
}

// Listen listens for task messages on the Pub/Sub subscription. Tasks are sent
// to the worker and results are then published to the Pub/Sub topic.
func (d *Dispatcher) Listen(ctx context.Context) error {
	return d.sub.Receive(ctx, func(ctx context.Context, msg *pubsub.Message) {
		// always ACK messages to avoid infinite loop handling a bad message
		defer msg.Ack()

		var req event.AuthRequest
		err := json.Unmarshal(msg.Data, &req)
		if err != nil {
			log.Printf("error unmarshaling: %s", err)
			return
		}

		ts := time.Now()
		if ts.After(req.NotAfter) {
			return
		}

		resp, err := d.wc.Submit(req)
		if err != nil {
			log.Printf("error from worker: %s", err)
			return
		}

		b, _ := json.Marshal(resp)
		d.resultc.Publish(ctx, &pubsub.Message{
			Data: b,
		})
	})
}
