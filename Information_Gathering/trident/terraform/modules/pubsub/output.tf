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


output "pubsub_topic_credentials" {
  description = "The name of credentials topic"
  value = google_pubsub_topic.credentials.name
}

output "pubsub_topic_results" {
  description = "The name of results topic"
  value = google_pubsub_topic.results.name
}

output "pubsub_subscription_credentials" {
  description = "The name of credentials subscription (used by dispatcher)"
  value = google_pubsub_subscription.credentials.name
}

output "pubsub_subscription_results" {
  description = "The name of results subscription (used by orchestrator consumer)"
  value = google_pubsub_subscription.results.name
}
