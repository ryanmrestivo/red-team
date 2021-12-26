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

package adfs

import (
	"bytes"
	"context"
	"crypto/tls"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"net/http"
	netUrl "net/url"
	"strings"
	"time"

	"github.com/Azure/go-ntlmssp"
	"golang.org/x/time/rate"

	"github.com/praetorian-inc/trident/pkg/event"
	"github.com/praetorian-inc/trident/pkg/nozzle"
)

const (
	// FrozenUserAgent is a static user agent that we use for all requests. This
	// value is based on the UA client hint work within browsers.
	// Additional details: https://bugs.chromium.org/p/chromium/issues/detail?id=955620
	FrozenUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" +
		"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3764.0 Safari/537.36"
)

var (
	// RateLimiter limits requests from the same worker to a maximum of 3/s
	RateLimiter = rate.NewLimiter(rate.Every(300*time.Millisecond), 1)
)

// Driver implements the nozzle.Driver interface.
type Driver struct{}

func init() {
	nozzle.Register("adfs", Driver{})
}

// New is used to create an adfs nozzle and accepts the following configuration
// options:
//
// domain
//
// The subdomain of the adfs organization. If a user logs in at
// https://example.adfs.com/adfs/ls, the value of domain is "example.adfs.com".
//
// strategy
//
// The authenticate strategy to use. This can be one of the following:
// usernamemixed (default) or ntlm (bypasses external lockout).
func (Driver) New(opts map[string]string) (nozzle.Nozzle, error) {
	domain, ok := opts["domain"]
	if !ok {
		return nil, fmt.Errorf("adfs nozzle requires 'domain' config parameter")
	}

	strategy, ok := opts["strategy"]
	if !ok {
		strategy = "idpinitiatedsignon"
	}

	return &Nozzle{
		Domain:    domain,
		Strategy:  strategy,
		UserAgent: FrozenUserAgent,
	}, nil
}

// Nozzle implements the nozzle.Nozzle interface for adfs.
type Nozzle struct {
	// Domain is the adfs subdomain
	Domain string

	// Strategy is the adfs authentication strategy
	Strategy string

	// UserAgent will override the Go-http-client user-agent in requests
	UserAgent string
}

var (
	windowsTransportURL     = "https://%s/adfs/services/trust/2005/windowstransport"
	windowsTransportRequest = `<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
	xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
	xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy"
	xmlns:wsa="http://www.w3.org/2005/08/addressing"
	xmlns:wst="http://schemas.xmlsoap.org/ws/2005/02/trust">
  <s:Header>
    <wsa:Action>http://schemas.xmlsoap.org/ws/2005/02/trust/RST/Issue</wsa:Action>
    <wsa:To>https://%s/adfs/services/trust/2005/windowstransport</wsa:To>
    <wsa:MessageID>1</wsa:MessageID>
  </s:Header>
  <s:Body>
    <wst:RequestSecurityToken><wst:RequestType>http://schemas.xmlsoap.org/ws/2005/02/trust/Issue</wst:RequestType>
      <wsp:AppliesTo>
        <wsa:EndpointReference>
          <wsa:Address>https://%s</wsa:Address>
        </wsa:EndpointReference>
      </wsp:AppliesTo>
     <wst:KeyType>http://schemas.xmlsoap.org/ws/2005/05/identity/NoProofKey</wst:KeyType>
    </wst:RequestSecurityToken>
  </s:Body>
</s:Envelope>`
	usernameMixedURL     = "https://%s/adfs/services/trust/2005/usernamemixed"
	usernameMixedRequest = `<?xml version="1.0" encoding="UTF-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"
            xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
            xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy"
            xmlns:wsa="http://www.w3.org/2005/08/addressing"
            xmlns:wst="http://schemas.xmlsoap.org/ws/2005/02/trust">
  <s:Header>
    <wsa:Action>http://schemas.xmlsoap.org/ws/2005/02/trust/RST/Issue</wsa:Action>
    <wsa:To>https://%s/adfs/services/trust/2005/usernamemixed</wsa:To>
    <wsa:MessageID>1</wsa:MessageID>
    <wsse:Security>
      <wsse:UsernameToken>
        <wsse:Username>%s</wsse:Username>
        <wsse:Password>%s</wsse:Password>
      </wsse:UsernameToken>
    </wsse:Security>
  </s:Header>
  <s:Body>
    <wst:RequestSecurityToken><wst:RequestType>http://schemas.xmlsoap.org/ws/2005/02/trust/Issue</wst:RequestType>
      <wsp:AppliesTo>
        <wsa:EndpointReference>
          <wsa:Address>https://%s/adfs/ls</wsa:Address>
        </wsa:EndpointReference>
      </wsp:AppliesTo>
     <wst:KeyType>http://schemas.xmlsoap.org/ws/2005/05/identity/NoProofKey</wst:KeyType>
    </wst:RequestSecurityToken>
  </s:Body>
</s:Envelope>`
	idpInitiatedSignonURL      = "https://%s/adfs/ls/idpinitiatedsignon"
	idpInitiatedSignonRequest1 = "SignInIdpSite=SignInIdpSite&SignInSubmit=Sign+in&SingleSignOut=SingleSignOut"
	msisSamlRequestCookie      = ""
	idpInitiatedSignonRequest2 = "UserName=%s&Password=%s&AuthMethod=FormsAuthentication"
)

func escape(s string) string {
	var b bytes.Buffer
	xml.EscapeText(&b, []byte(s)) // nolint:gosec,errcheck
	return b.String()
}

func (n *Nozzle) ntlmStrategy(username, password string) (*event.AuthResponse, error) {
	url := fmt.Sprintf(windowsTransportURL, n.Domain)
	data := fmt.Sprintf(windowsTransportRequest, n.Domain, n.Domain)

	client := &http.Client{
		Transport: ntlmssp.Negotiator{
			RoundTripper: &http.Transport{
				TLSClientConfig: &tls.Config{
					InsecureSkipVerify: true, // nolint:gosec
				},
			},
		},
	}

	req, _ := http.NewRequest("GET", url, strings.NewReader(data))
	req.SetBasicAuth(username, password)
	req.Header.Set("Content-Type", "application/soap+xml")
	req.Header.Set("User-Agent", n.UserAgent)
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() // nolint:errcheck

	if resp.StatusCode == 503 {
		return nil, fmt.Errorf("ntlm not enabled externally")
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return &event.AuthResponse{
		Valid:  resp.StatusCode == 200,
		MFA:    false,
		Locked: false,
		Metadata: map[string]interface{}{
			"xml": string(body),
		},
	}, nil
}

func (n *Nozzle) usernameMixedStrategy(username, password string) (*event.AuthResponse, error) {
	url := fmt.Sprintf(usernameMixedURL, n.Domain)
	data := fmt.Sprintf(usernameMixedRequest,
		n.Domain, escape(username), escape(password), n.Domain)

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true, // nolint:gosec
			},
		},
	}

	req, _ := http.NewRequest("GET", url, strings.NewReader(data))
	req.Header.Set("Content-Type", "application/soap+xml")
	req.Header.Set("User-Agent", n.UserAgent)
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() // nolint:errcheck

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return &event.AuthResponse{
		Valid:  resp.StatusCode == 200,
		MFA:    false,
		Locked: false,
		Metadata: map[string]interface{}{
			"status": resp.StatusCode,
			"xml":    string(body),
		},
	}, nil
}

func (n *Nozzle) idpInitiatedSignon(username, password string) (*event.AuthResponse, error) {
	// Set the MSISSamlRequest cookie
	if msisSamlRequestCookie == "" {
		err := n.setMSISSamlRequestCookie()
		if err != nil {
			return nil, err
		}
	}

	url := fmt.Sprintf(idpInitiatedSignonURL, n.Domain)
	data := fmt.Sprintf(idpInitiatedSignonRequest2, netUrl.QueryEscape(username), netUrl.QueryEscape(password))

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true, // nolint:gosec
			},
		},
		// Ignore the redirect
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}

	req, _ := http.NewRequest("POST", url, strings.NewReader(data))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("User-Agent", n.UserAgent)
	req.AddCookie(&http.Cookie{Name: "MSISSamlRequest", Value: msisSamlRequestCookie})
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close() // nolint:errcheck

	var MSISAuthCookie = ""
	for _, cookie := range resp.Cookies() {
		if cookie.Name == "MSISAuth" {
			MSISAuthCookie = cookie.Value
		}
	}

	return &event.AuthResponse{
		Valid:  resp.StatusCode == 302,
		MFA:    false,
		Locked: false,
		Metadata: map[string]interface{}{
			"status":         resp.StatusCode,
			"MSISAuthCookie": MSISAuthCookie,
		},
	}, nil
}

func (n *Nozzle) setMSISSamlRequestCookie() error {
	url := fmt.Sprintf(idpInitiatedSignonURL, n.Domain)
	data := idpInitiatedSignonRequest1

	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true, // nolint:gosec
			},
		},
	}

	req, _ := http.NewRequest("POST", url, strings.NewReader(data))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("User-Agent", n.UserAgent)
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close() // nolint:errcheck

	for _, cookie := range resp.Cookies() {
		if cookie.Name == "MSISSamlRequest" {
			msisSamlRequestCookie = cookie.Value
		}
	}

	if msisSamlRequestCookie == "" {
		return fmt.Errorf("MSISSamlRequest cookie was not in the HTTP response")
	}

	return nil
}

// Login fulfils the nozzle.Nozzle interface and performs an authentication
// requests against adfs. This function supports rate limiting and parses valid,
// invalid, and locked out responses.
func (n *Nozzle) Login(username, password string) (*event.AuthResponse, error) {
	ctx := context.Background()
	err := RateLimiter.Wait(ctx)
	if err != nil {
		return nil, err
	}

	if n.Strategy == "ntlm" {
		return n.ntlmStrategy(username, password)
	}

	if n.Strategy == "usernamemixed" {
		return n.usernameMixedStrategy(username, password)
	}

	// Default strategy is idpinitiatedsignon
	return n.idpInitiatedSignon(username, password)
}
