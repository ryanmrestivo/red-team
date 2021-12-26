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

package commands

import (
	"bytes"
	"encoding/json"
	"net/http"

	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"

	"github.com/praetorian-inc/trident/pkg/db"
)

var cancelCommand = &cobra.Command{
	Use:   "cancel",
	Short: "cancel campaign execution",
	Long:  `can be used to halt a running campaign and stop all further spraying.`,
	Run: func(cmd *cobra.Command, args []string) {
		cancelPost(cmd, args)
	},
}

func init() {
	cancelCommand.Flags().UintVarP(&campaignID, "campaign", "c", 0,
		"the identifier of the campaign.")
	err := cancelCommand.MarkFlagRequired("campaign")
	if err != nil {
		log.Fatalf("issue during argument parsing: %s", err)
	}

	campaignCmd.AddCommand(cancelCommand)
}

func updateStatus(cID uint, status db.CampaignStatus) {
	orchestrator := viper.GetString("orchestrator-url")

	q := map[string]interface{}{
		"ID":     cID,
		"Status": status,
	}

	buf := new(bytes.Buffer)
	err := json.NewEncoder(buf).Encode(q)
	if err != nil {
		log.Fatalf("error encoding cancel json request: %s", err)
	}

	req, err := http.NewRequest("POST", orchestrator+"/campaign/status", buf)

	if err != nil {
		log.Fatalf("error during request creation: %s", err)
	}

	// add Cloudflare Access token to our request
	err = authenticator.Auth(req)
	if err != nil {
		log.Fatalf("error during authentication: %s", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Fatalf("error sending request: %s", err)
	}
	defer resp.Body.Close() // nolint:errcheck

	// handle the results from the server
	if resp.StatusCode != 200 {
		log.Fatalf("error cancelling campaign from server: %d", resp.StatusCode)
	}
}

// cancelPost will post the parameters update the Status
// of the campaign specified by the provided ID to CampaignStatusCancelled
func cancelPost(cmd *cobra.Command, args []string) {
	updateStatus(campaignID, db.CampaignStatusCancelled)
}
