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
  name = "orchestrator"

  labels = {
    app = "orchestrator"
  }

  env = {
    "PROJECT_ID"           = var.project,
    "TOPIC_ID"             = var.pubsub_topic,
    "SUBSCRIPTION_ID"      = var.pubsub_subscription,
    "ADMIN_LISTENING_PORT" = "8000",
    "REDIS_URI"            = "${google_redis_instance.cache.host}:${google_redis_instance.cache.port}",
    "CF_AUTH_DOMAIN"       = var.cloudflare_auth_domain,
    "CF_AUDIENCE"          = var.cloudflare_audience,
  }
}

# Memorystore (Redis)

resource "random_id" "redis_suffix" {
  byte_length = 4
}

resource "google_redis_instance" "cache" {
  name           = "trident-cache-${random_id.redis_suffix.hex}"
  region         = var.location
  tier           = "STANDARD_HA"
  memory_size_gb = 1

  authorized_network = var.network
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version     = "REDIS_5_0"
}

# Cloud SQL

resource "random_password" "db" {
  length = 24
  special = false
}

resource "google_sql_database" "db" {
  name     = "trident"
  instance = var.db_instance_name
}

resource "google_sql_user" "user" {
  instance = var.db_instance_name
  name     = "trident"
  host     = null
  password = random_password.db.result
}

resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.server.email}"
}

# Service Account

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

# Cloud Pub/Sub

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

# Kubernetes deployment

resource "kubernetes_service_account" "server" {
  metadata {
    namespace   = var.namespace
    name        = local.name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.server.email
    }
  }
}

resource "kubernetes_secret" "db" {
  metadata {
    namespace = var.namespace
    name = "db"
  }

  data = {
    "connection" = "postgres://${google_sql_user.user.name}:${random_password.db.result}@127.0.0.1/${google_sql_database.db.name}?sslmode=disable"
  }
}

resource "kubernetes_secret" "tunnel" {
  metadata {
    namespace = var.namespace
    name = "tunnel"
  }

  data = {
    "cert.pem" = var.cloudflare_cert
  }
}

resource "kubernetes_deployment" "server" {
  metadata {
    namespace = var.namespace
    name      = local.name
    labels    = local.labels
  }

  spec {
    replicas = 1

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
            name = "DB_CONNECTION_STRING"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db.metadata[0].name
                key  = "connection"
              }
            }
          }
        }

        container {
          image = "gcr.io/cloudsql-docker/gce-proxy:latest"
          name  = "cloud-sql-proxy"

          command = ["/cloud_sql_proxy", "-instances=${var.db_connection_name}=tcp:5432"]
        }

        container {
          image   = "docker.io/cloudflare/cloudflared:2020.7.1"
          name    = "tunnel"
          command = ["cloudflared", "tunnel"]
          args    = [
            "--url=http://127.0.0.1:8000",
            "--hostname=${var.cloudflare_domain}",
            "--origincert=/etc/cloudflared/cert.pem",
            "--no-autoupdate"
          ]

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            mount_path = "/etc/cloudflared"
            name       = "tunnel-secret"
            read_only  = true
          }

        }

        volume {
          name = "tunnel-secret"
          secret {
            secret_name = kubernetes_secret.tunnel.metadata[0].name
          }
        }
      }
    }
  }
}
