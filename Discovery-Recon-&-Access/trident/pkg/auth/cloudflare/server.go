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
	"context"
	"fmt"
	"log"
	"net/http"
	"net/url"

	"github.com/coreos/go-oidc/v3/oidc"

	"github.com/praetorian-inc/trident/pkg/util"
)

// Verifier returns a function that is used to verify the Cloudflare access token
func Verifier(authDomain string, policyAUD string) func(http.Handler) http.Handler {
	u, err := url.Parse(authDomain)
	if err != nil {
		log.Fatalf("authDomain not a valid url: %s", err)
	}
	certsURL := fmt.Sprintf("https://%s/cdn-cgi/access/certs", u.Host)
	err = util.ValidateURLSuffix(certsURL, ".cloudflareaccess.com")
	if err != nil {
		log.Fatalf("cloudflare access url validation failed: %s", err)
	}

	config := &oidc.Config{
		ClientID: policyAUD,
	}

	ctx := context.TODO()
	keySet := oidc.NewRemoteKeySet(ctx, certsURL)
	verifier := oidc.NewVerifier(authDomain, keySet, config)

	return func(next http.Handler) http.Handler {
		return VerifyToken(verifier)(next)
	}
}

// VerifyToken is a middleware to verify a CF Access token
func VerifyToken(verifier *oidc.IDTokenVerifier) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		hfn := func(w http.ResponseWriter, r *http.Request) {
			headers := r.Header
			// Verify the request contains an access token signed by Cloudflare
			accessJWT := headers.Get("Cf-Access-Jwt-Assertion")
			if accessJWT == "" {
				w.WriteHeader(http.StatusUnauthorized)
				_, err := w.Write([]byte("No token on the request"))
				if err != nil {
					log.Printf("error writing to http response: %s", err)
				}
				return
			}

			// Verify the access token
			ctx := r.Context()
			_, err := verifier.Verify(ctx, accessJWT)
			if err != nil {
				w.WriteHeader(http.StatusUnauthorized)
				_, err = w.Write([]byte(fmt.Sprintf("Invalid token: %s", err.Error())))
				if err != nil {
					log.Printf("error writing to http response: %s", err)
				}
				return
			}
			next.ServeHTTP(w, r)
		}
		return http.HandlerFunc(hfn)
	}
}
