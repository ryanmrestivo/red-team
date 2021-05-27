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

# -----------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# -----------------------------------------------------------------------------

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The location (region or zone) to host the cluster in"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace for deployment"
  type        = string
}

variable "image" {
  description = "The container image to deploy"
  type        = string
}

variable "network" {
  description = "The VPC network ID for redis"
  type        = string
}

variable "pubsub_topic" {
  description = "The name of the PubSub topic to publish credentials to"
  type        = string
}

variable "pubsub_subscription" {
  description = "The name of the PubSub subscription to fetch results from"
  type        = string
}

variable "db_instance_name" {
  description = "The name of the Cloud SQL database instance"
  type        = string
}

variable "db_connection_name" {
  description = "The connection name of the Cloud SQL database instance"
  type        = string
}

variable "cloudflare_auth_domain" {
  description = "The Cloudflare access authentication domain"
  type        = string
}

variable "cloudflare_domain" {
  description = "The Cloudflare domain to host this service on"
  type        = string
}

variable "cloudflare_audience" {
  description = "The Cloudflare access audience"
  type        = string
}

variable "cloudflare_cert" {
  description = "The Cloudflare certificate and private key blob"
  type        = string
}

# -----------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# -----------------------------------------------------------------------------
