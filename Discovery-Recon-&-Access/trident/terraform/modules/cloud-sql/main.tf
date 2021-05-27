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


resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  project = var.project
  region  = var.location
  name    = "${var.database_instance_name}-${random_id.db_suffix.hex}"

  database_version = var.database_version

  settings {
    tier = var.database_machine_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network_id
    }
  }
}
