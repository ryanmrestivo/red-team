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

variable "namespace" {
  description = "The Kubernetes namespace for deployment"
  type        = string
}

variable "image" {
  description = "The container image to deploy"
  type        = string
}

variable "pubsub_topic" {
  description = "The name of the PubSub topic to publish results to"
  type        = string
}

variable "pubsub_subscription" {
  description = "The name of the PubSub subscription to fetch jobs from"
  type        = string
}

variable "worker_url" {
  description = "The URL to a webhook worker for job submission"
  type        = string
}

variable "worker_token" {
  description = "The access token to use when authenticating to a worker"
  type        = string
}

# -----------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# -----------------------------------------------------------------------------

variable "worker_name" {
  description = "The type of worker to submit jobs to"
  type        = string
  default     = "webhook"
}
