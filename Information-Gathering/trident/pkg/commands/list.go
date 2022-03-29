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
	"encoding/json"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/jedib0t/go-pretty/table"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"

	"github.com/praetorian-inc/trident/pkg/db"
)

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "campaign list reporting subcommand",
	Long:  `can be used to list the currently tracked campaigns`,
	Run: func(cmd *cobra.Command, args []string) {
		listGet(cmd, args)
	},
}

var listTableHeaderNames = []string{
	"campaign id",
	"provider",
	"metadata",
	"status",
	"creation date",
}

var listTableHeaderFields = []string{
	"id",
	"provider",
	"provider_metadata",
	"status",
	"created_at",
}

func init() {
	campaignCmd.AddCommand(listCmd)
}

// listGet will retrieve a list of the currently tracked campaigns
// and print that list to the CLI
func listGet(cmd *cobra.Command, args []string) {
	orchestrator := viper.GetString("orchestrator-url")

	req, err := http.NewRequest("GET", orchestrator+"/list", nil)
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
	respBody, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalf("error reading response body: %s", err)
	}

	var results []map[string]interface{}
	err = json.Unmarshal(respBody, &results)
	if err != nil {
		log.Fatalf("error parsing response json: %s", err)
	}

	t := table.NewWriter()
	t.SetOutputMirror(os.Stdout)

	header := make(table.Row, 0, len(listTableHeaderNames))
	for _, field := range listTableHeaderNames {
		header = append(header, field)
	}
	t.AppendHeader(header)

	for _, result := range results {
		var row table.Row
		for _, field := range listTableHeaderFields {
			v, ok := result[field]
			if !ok {
				log.Fatal("there was an error retrieving results from the map")
			}
			// Legacy handling for campaigns created pre-Status implementation
			if field == "status" && v == "" {
				row = append(row, db.CampaignStatusActive)
			} else {
				row = append(row, v)
			}
		}
		t.AppendRows([]table.Row{row})
	}

	if flagOutputFormat == "csv" {
		t.RenderCSV()
		return
	}

	t.Render()
}
