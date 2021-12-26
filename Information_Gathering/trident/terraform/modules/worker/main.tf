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


resource "random_id" "token" {
  byte_length = 16
}

resource "google_cloud_run_service" "worker" {
  project  = var.project
  location = var.location
  name     = "webhook-worker"

  template {
    spec {
      containers {
        image = var.image

        env {
          name = "ACCESS_TOKEN"
          value = random_id.token.hex
        }
      }
    }
  }

  autogenerate_revision_name = true
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  project  = google_cloud_run_service.worker.project
  location = google_cloud_run_service.worker.location
  service  = google_cloud_run_service.worker.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
