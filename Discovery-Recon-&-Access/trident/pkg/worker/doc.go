// Copyright 2020 Praetorian Security, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Package worker houses several packages which accept tasks in some manner
// (e.g. webhooks), open the relevant nozzle, send the requested credential
// guess, and return the response. An novel worker example is to send tasks via
// command & control to a victim machine and perform the credential guesses from
// that victim machine in the target network.
package worker
