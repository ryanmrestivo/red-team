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

// Package nozzle defines an interface for all password spraying implementations
// For example, an Okta nozzle will send login requests to Okta. Additionally,
// this package provides a nozzle registration mechanism similar to
// database/sql. Make sure to "blank import" each nozzle.
//
//  import (
//      "github.com/praetorian-inc/trident/pkg/nozzle"
//
//      _ "github.com/praetorian-inc/trident/pkg/nozzle/adfs"
//      _ "github.com/praetorian-inc/trident/pkg/nozzle/o365"
//      _ "github.com/praetorian-inc/trident/pkg/nozzle/okta"
//  )
//
//  noz, err := nozzle.Open("okta", map[string]string{"subdomain":"example"})
//  if err != nil {
//      // handle error
//  }
//  resp, err := noz.Login("username", "password")
//  // ...
//
// See https://golang.org/doc/effective_go.html#blank_import for more
// information on "blank imports".
package nozzle

import (
	"fmt"
	"sync"

	"github.com/praetorian-inc/trident/pkg/event"
)

var (
	driversMu sync.RWMutex
	drivers   = make(map[string]Driver)
)

// Driver is the interface the wraps creation of a Nozzle.
type Driver interface {
	New(opts map[string]string) (Nozzle, error)
}

// Nozzle is the interface that wraps a basic Login() method to be implemented for
// each authentication provider we support.
type Nozzle interface {
	Login(username, password string) (*event.AuthResponse, error)
}

// Open opens a nozzle specified by the nozzle driver name (e.g. okta) and
// configures that nozzle via the provided opts argument. Each Nozzle should
// document its configuration options in its New() method.
func Open(name string, opts map[string]string) (Nozzle, error) {
	driversMu.RLock()
	n, ok := drivers[name]
	driversMu.RUnlock()
	if !ok {
		return nil, fmt.Errorf("nozzle: unknown driver %q (forgotten import?)", name)
	}

	return n.New(opts)
}

// Register makes a nozzle driver available at the provided name. If register is
// called twice or if the driver is nil, if panics. Register() is typically
// called in the nozzle implementation's init() function to allow for easy
// importing of each nozzle.
func Register(name string, driver Driver) {
	driversMu.Lock()
	defer driversMu.Unlock()
	if driver == nil {
		panic("nozzle: Register driver is nil")
	}
	if _, dup := drivers[name]; dup {
		panic("nozzle: Register called twice for driver " + name)
	}
	drivers[name] = driver
}
