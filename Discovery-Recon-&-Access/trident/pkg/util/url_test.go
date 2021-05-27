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

package util

import (
	"fmt"
	"testing"
)

type testcase struct {
	input     string
	domain    string
	expecterr bool
}

func TestValidation(t *testing.T) {
	var testcases = []testcase{
		{"example", ".okta.com", false},
		{"example", "okta.com", true},
		{"example.com/", ".okta.com", true},
		{"example", ".example.com", true},
	}
	for _, test := range testcases {
		url := fmt.Sprintf("https://%s.okta.com/api/v1/authn", test.input)
		err := ValidateURLSuffix(url, test.domain)
		if test.expecterr && (err == nil) {
			t.Errorf("expected validation error for (%s, %s)", test.input, test.domain)
		}
		if !test.expecterr && (err != nil) {
			t.Errorf("unexpected validation error for (%s, %s): %s", test.input, test.domain, err)
		}
	}

	testcases = []testcase{
		{"https://example.okta.com", ".okta.com", false},
		{"file:///example.okta.com", ".okta.com", true},
		{"http://example.okta.com", "okta.com", true},
	}
	for _, test := range testcases {
		err := ValidateURLSuffix(test.input, test.domain)
		if test.expecterr && (err == nil) {
			t.Errorf("expected validation error for (%s, %s)", test.input, test.domain)
		}
		if !test.expecterr && (err != nil) {
			t.Errorf("unexpected validation error for (%s, %s): %s", test.input, test.domain, err)
		}
	}

}
