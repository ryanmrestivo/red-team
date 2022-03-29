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

package dispatch

import (
	"encoding/json"
	"fmt"
	"sync"

	"github.com/praetorian-inc/trident/pkg/event"
)

var (
	driversMu sync.RWMutex
	drivers   = make(map[string]Driver)
)

// WorkerClient is an interface that wraps the Submit function, which simply
// accepts and AuthRequest, performs work, and returns an AuthResponse.
type WorkerClient interface {
	Submit(event.AuthRequest) (*event.AuthResponse, error)
}

// Driver is an interface which wraps the creation of a WorkerClient.
type Driver interface {
	New(opts map[string]string) (WorkerClient, error)
}

// WorkerOptions is a tyoe alias for simple marshaling/unmarshaling of worker
// configuration options.
type WorkerOptions map[string]string

// UnmarshalText implements the encoding.Textunmarshaler interface.
func (opts *WorkerOptions) UnmarshalText(text []byte) error {
	return json.Unmarshal(text, opts)
}

// UnmarshalJSON implements the encoding/json.Unmarshaler interface.
func (opts *WorkerOptions) UnmarshalJSON(b []byte) error {
	var s map[string]string
	if err := json.Unmarshal(b, &s); err != nil {
		return err
	}
	*opts = WorkerOptions(s)
	return nil
}

// Open opens a worker client specified by the client driver name (e.g. webhook)
// and configures that client via the provided opts argument. Each WorkerClient
// should document its configuration options in its New() method.
func Open(name string, opts WorkerOptions) (WorkerClient, error) {
	driversMu.RLock()
	n, ok := drivers[name]
	driversMu.RUnlock()
	if !ok {
		return nil, fmt.Errorf("workerclient: unknown driver %q (forgotten import?)", name)
	}

	return n.New(opts)
}

// Register makes a client driver available at the provided name. If register is
// called twice or if the driver is nil, if panics. Register() is typically
// called in the client implementation's init() function to allow for easy
// importing of each client.
func Register(name string, driver Driver) {
	driversMu.Lock()
	defer driversMu.Unlock()
	if driver == nil {
		panic("workerclient: Register driver is nil")
	}
	if _, dup := drivers[name]; dup {
		panic("workerclient: Register called twice for driver " + name)
	}
	drivers[name] = driver
}
