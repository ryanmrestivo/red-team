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


locals {
  name = "dispatcher"

  labels = {
    app = "dispatcher"
  }

  env = {
    "PROJECT_ID"      = var.project,
    "RESULT_TOPIC_ID" = var.pubsub_topic,
    "SUBSCRIPTION_ID" = var.pubsub_subscription,
    "WORKER_NAME"     = var.worker_name,
  }

  worker_config = jsonencode({
    "url"   = var.worker_url,
    "token" = var.worker_token,
  })
}

resource "google_service_account" "server" {
  project      = var.project
  account_id   = "trident-${local.name}-sa"
  display_name = "Trident ${local.name}"
}

resource "google_service_account_iam_member" "workload-identity" {
  service_account_id = google_service_account.server.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[${var.namespace}/${local.name}]"
}

resource "google_pubsub_topic_iam_member" "server-topic" {
  topic  = var.pubsub_topic
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.server.email}"
}

resource "google_pubsub_subscription_iam_member" "server-subscription" {
  subscription = var.pubsub_subscription
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.server.email}"
}

resource "kubernetes_service_account" "server" {
  metadata {
    namespace   = var.namespace
    name        = local.name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.server.email
    }
  }
}

resource "kubernetes_config_map" "worker" {
  metadata {
    namespace = var.namespace
    name      = "dispatcher-worker"
  }

  data = {
    config = local.worker_config
  }
}

resource "kubernetes_deployment" "server" {
  metadata {
    namespace = var.namespace
    name      = local.name
    labels    = local.labels
  }

  spec {
    replicas = 20

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        service_account_name = kubernetes_service_account.server.metadata[0].name
        container {
          image = var.image
          name  = local.name

          dynamic "env" {
            for_each = local.env
            content {
              name  = env.key
              value = env.value
            }
          }

          env {
            name = "WORKER_CONFIG"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.worker.metadata[0].name
                key  = "config"
              }
            }
          }
        }
      }
    }
  }
}
