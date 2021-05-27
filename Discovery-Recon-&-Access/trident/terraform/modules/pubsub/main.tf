/**
 * Copyright 2020 Praetorian Security, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


resource "google_pubsub_topic" "credentials" {
  project = var.project
  name    = "trident-credentials"
}

resource "google_pubsub_topic" "results" {
  project = var.project
  name    = "trident-results"
}

resource "google_pubsub_subscription" "credentials" {
  project = var.project
  name    = "trident-dispatcher-credentials"
  topic   = google_pubsub_topic.credentials.id

  ack_deadline_seconds = 300
}

resource "google_pubsub_subscription" "results" {
  project = var.project
  name    = "trident-orchestrator-results"
  topic   = google_pubsub_topic.results.id

  ack_deadline_seconds = 300
}
