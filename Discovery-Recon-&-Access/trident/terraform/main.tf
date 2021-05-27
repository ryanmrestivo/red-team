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


terraform {
  required_version = ">= 0.13"
}

provider "google" {
  version = "~> 3.37.0"

  project = var.project
  region  = var.location
}

provider "google-beta" {
  version = "~> 3.37.0"

  project = var.project
  region  = var.location
}

data "google_client_config" "provider" {}

data "google_project" "project" {
  project_id = var.project
}

provider "random" {}

resource "google_project_service" "services" {
  project = var.project
  for_each = toset([
    "container.googleapis.com",
    "redis.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

module "backend_networking" {
  # When using these modules in your own templates, you will need to use a Git
  # URL with a ref attribute that pins you to a specific version of the modules,
  # such as the following example:
  # source = "github.com/praetorian-inc/trident.git//terraform/modules/vpc-networking?ref=v0.1.0"
  source = "./modules/vpc-networking"

  depends_on = [
    google_project_service.services["servicenetworking.googleapis.com"],
  ]
}

module "cloud_sql" {
  source = "./modules/cloud-sql"

  project  = data.google_project.project.project_id
  location = var.location

  private_network_id     = module.backend_networking.private_network_id

  depends_on = [
    module.backend_networking,
    google_project_service.services["sql-component.googleapis.com"],
    google_project_service.services["sqladmin.googleapis.com"],
  ]
}

module "gke_cluster" {
  source = "./modules/gke-cluster"

  project  = data.google_project.project.project_id
  location = var.location
  name     = var.cluster_name

  network  = module.backend_networking.private_network_id

  depends_on = [
    google_project_service.services["container.googleapis.com"],
  ]
}

provider "kubernetes" {
  version = "~> 1.13.0"

  load_config_file = false

  host  = "https://${module.gke_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "trident"
  }
  # force a dependency on the node pool to avoid destroying the ns after the pool
  depends_on = [module.gke_cluster.node_pool]
}

module "pubsub" {
  source = "./modules/pubsub"

  project = data.google_project.project.project_id
}

module "worker" {
  source = "./modules/worker"

  project  = data.google_project.project.project_id
  location = var.location

  image = var.worker_image

  depends_on = [
    google_project_service.services["run.googleapis.com"],
  ]
}

module "dispatcher" {
  source = "./modules/dispatcher"

  project   = data.google_project.project.project_id
  namespace = kubernetes_namespace.ns.metadata[0].name

  pubsub_topic        = module.pubsub.pubsub_topic_results
  pubsub_subscription = module.pubsub.pubsub_subscription_credentials

  worker_url   = module.worker.endpoint
  worker_token = module.worker.token

  image = var.dispatcher_image

  depends_on = [
    google_project_service.services["container.googleapis.com"],
  ]
}

module "orchestrator" {
  source = "./modules/orchestrator"

  project   = data.google_project.project.project_id
  location  = var.location
  namespace = kubernetes_namespace.ns.metadata[0].name

  network = module.backend_networking.private_network_id

  pubsub_topic        = module.pubsub.pubsub_topic_credentials
  pubsub_subscription = module.pubsub.pubsub_subscription_results

  db_instance_name   = module.cloud_sql.instance_name
  db_connection_name = module.cloud_sql.connection_name

  cloudflare_auth_domain = var.cloudflare_auth_domain
  cloudflare_domain      = var.cloudflare_domain
  cloudflare_audience    = var.cloudflare_audience
  cloudflare_cert        = "${file("~/.cloudflared/cert.pem")}"

  image = var.orchestrator_image

  depends_on = [
    google_project_service.services["container.googleapis.com"],
    google_project_service.services["redis.googleapis.com"],
  ]
}
