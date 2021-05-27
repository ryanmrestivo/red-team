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

package webhook

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/praetorian-inc/trident/pkg/dispatch"
	"github.com/praetorian-inc/trident/pkg/event"
)

func init() {
	dispatch.Register("webhook", Driver{})
}

// Driver implements the dispatch.WorkerClient interface.
type Driver struct{}

// New is used to create a webhook worker client and accepts the following
// configuration options:
//  url:    an HTTPS link to the webhook server.
//  token:  a shared secret used to authenticate the client to the webhook server.
//  header: the HTTP header used for authentication (defaults to X-Access-Token).
func (Driver) New(opts map[string]string) (dispatch.WorkerClient, error) {
	url, ok := opts["url"]
	if !ok {
		return nil, fmt.Errorf("webhook client requires 'url' config parameter")
	}
	token, ok := opts["token"]
	if !ok {
		return nil, fmt.Errorf("webhook client requires 'token' config parameter")
	}
	header, ok := opts["header"]
	if !ok {
		header = "X-Access-Token"
	}
	return &Client{
		URL:    url,
		Header: header,
		Token:  token,
	}, nil
}

// Client implements the dispatch.WorkerClient interface for webhooks.
type Client struct {
	// URL is the HTTPS URL to a worker
	URL string

	// Header is the HTTP header used to set the access token
	// Header defaults to X-Access-Token
	Header string

	// Token is an authorization token used to communicate with the worker
	Token string
}

// Submit fulfils the dispatch.WorkerClient interface and submits a task to the
// configured webhook server.
func (w *Client) Submit(r event.AuthRequest) (*event.AuthResponse, error) {
	data, _ := json.Marshal(r)
	req, err := http.NewRequest("POST", w.URL, bytes.NewBuffer(data))
	if err != nil {
		return nil, err
	}
	req.Header.Set(w.Header, w.Token)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() // nolint:errcheck

	if resp.StatusCode != 200 {
		var res event.ErrorResponse
		err = json.NewDecoder(resp.Body).Decode(&res)
		if err != nil {
			return nil, err
		}
		return nil, errors.New(res.ErrorMsg)
	}

	var res event.AuthResponse
	err = json.NewDecoder(resp.Body).Decode(&res)
	return &res, err
}
