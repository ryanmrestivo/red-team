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

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cloudflare_auth_domain" {
  description = "The Cloudflare Access authentication domain (e.g. https://example.cloudflareaccess.com)"
  type        = string
}

variable "cloudflare_domain" {
  description = "The Cloudflare Access domain (e.g. trident.operator.dev)"
  type        = string
}

variable "cloudflare_audience" {
  description = "The Cloudflare Access audience (64 hex chars)"
  type        = string
}

# -----------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# -----------------------------------------------------------------------------

variable "worker_image" {
  description = "The container image ref for worker"
  type        = string
  default     = "gcr.io/praetorian-red-team-public/webhook-worker:latest"
}

variable "dispatcher_image" {
  description = "The container image ref for dispatcher"
  type        = string
  default     = "gcr.io/praetorian-red-team-public/dispatcher:latest"
}

variable "orchestrator_image" {
  description = "The container image ref for orchestrator"
  type        = string
  default     = "gcr.io/praetorian-red-team-public/orchestrator:latest"
}
