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
	"fmt"
	"net/http"

	"github.com/praetorian-inc/trident/pkg/db"

	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	// identifier for the campaign
	campaignID uint
)

var describeCmd = &cobra.Command{
	Use:   "describe",
	Short: "campaign describe reporting subcommand",
	Long:  `can be used to return the parameters that makeup a given campaign.`,
	Run: func(cmd *cobra.Command, args []string) {
		describeGet(cmd, args)
	},
}

func init() {
	describeCmd.Flags().UintVarP(&campaignID, "campaign", "c", 0,
		"the identifier of the campaign.")
	err := describeCmd.MarkFlagRequired("campaign")
	if err != nil {
		log.Fatalf("issue during argument parsing: %d", err)
	}

	campaignCmd.AddCommand(describeCmd)
}

// describeGet will retrieve the parameters that make up the given campaign
// and print the parameters to the CLI
func describeGet(cmd *cobra.Command, args []string) {
	orchestrator := viper.GetString("orchestrator-url")

	var flagFilter = fmt.Sprintf("{\"id\":%d}", campaignID)

	var filter map[string]interface{}
	err := json.Unmarshal([]byte(flagFilter), &filter)
	if err != nil {
		log.Fatalf("error during JSON unmarshalling: %s", err)
	}

	// build our request to the orchestrator.
	// return all fields (*) and the filter is the campaignID
	requestBody, err := json.Marshal(map[string]interface{}{
		"Filter": filter,
	})
	if err != nil {
		log.Fatalf("error during JSON marshalling for request body: %s", err)
	}

	req, err := http.NewRequest("POST", orchestrator+"/describe", bytes.NewBuffer(requestBody))
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
		log.Fatalf("error returning results from server: %d", resp.StatusCode)
	}

	var campaign db.Campaign
	err = json.NewDecoder(resp.Body).Decode(&campaign)
	if err != nil {
		log.Fatalf("error parsing response json: %s", err)
	}

	fmt.Printf("-------------------------------------------\n")
	fmt.Printf("Campaign #%d Parameters:\n", campaignID)
	fmt.Printf("-------------------------------------------\n")
	fmt.Printf("Start Time:     %s\n", campaign.NotBefore)
	fmt.Printf("End Time:       %s\n", campaign.NotAfter)
	if campaign.Status != "" {
		fmt.Printf("Status:         %s\n", campaign.Status)
	} else {
		fmt.Printf("Status:         %s\n", db.CampaignStatusActive)
	}
	fmt.Printf("User Count:     %d\n", len(campaign.Users))
	fmt.Printf("Password Count: %d\n", len(campaign.Passwords))
	fmt.Printf("Provider:       %s\n", campaign.Provider)
	fmt.Printf("Metadata:       %s\n", campaign.ProviderMetadata)
}
