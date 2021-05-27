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

package cloudflare

import (
	"net/http"
	"net/url"

	"github.com/cloudflare/cloudflared/cmd/cloudflared/token"
	"github.com/cloudflare/cloudflared/logger"
)

// ArgoAuthenticator implements the Authenticator interface. the only metadata
// required by the Argo token fetcher is the target URL.
type ArgoAuthenticator struct {
	URL *url.URL
}

// Auth allows an ArgoAuthenticator to fetch the appropriate token for use in
// authenticate a request to the cloudflare service. this function calls into
// Cloudflared's token package to accomplish this. it then sets the
// `cf-access-token` header for the provided request.
func (a *ArgoAuthenticator) Auth(req *http.Request) error {
	logger, err := logger.New()
	if err != nil {
		return err
	}

	token, err := token.FetchToken(a.URL, logger)
	if err != nil {
		return err
	}

	req.Header.Set("cf-access-token", token)

	return nil
}
