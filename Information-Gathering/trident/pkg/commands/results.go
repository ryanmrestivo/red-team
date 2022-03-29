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
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"github.com/jedib0t/go-pretty/table"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	// holds a list of fields (csv) to be included in the returned output
	flagReturnedFields string

	// a JSON filter to use in a database query
	flagFilter string

	// the desired format for output (csv, json, table)
	flagOutputFormat string
)

var (
	// DefaultReturnedFields lists the minimum fields needed for an operator
	// to monitor the success/failure of a spraying campaign
	DefaultReturnedFields = []string{
		"id",
		"username",
		"password",
		"valid",
	}
)

var resultsCmd = &cobra.Command{
	Use:   "results",
	Short: "results reporting subcommand",
	Long:  `can be used to return results from the server about the currently configured campaigns`,
	Run: func(cmd *cobra.Command, args []string) {
		resultsGet(cmd, args)
	},
}

func init() {
	// default: * (all fields)
	resultsCmd.Flags().StringVarP(&flagReturnedFields, "return", "r", "*",
		"the list of fields you would like to see from the results (comma-separated string)")

	// default: {"valid": true}, returns all valid credentials in the campaign
	resultsCmd.Flags().StringVarP(&flagFilter, "filter", "f", `{"valid":true}`,
		"filter on db results (specified in JSON)")

	// default: table (terminal friendly)
	resultsCmd.Flags().StringVarP(&flagOutputFormat, "output-format", "o", "table",
		"output format (table, csv, json)")
	rootCmd.AddCommand(resultsCmd)
}

// resultsGet will request a set of results from the orchestrator using the
// provided database filter, and field specification. then, it will format those
// results into either a csv, json, or terminal-friendly table for output.
func resultsGet(cmd *cobra.Command, args []string) {
	orchestrator := viper.GetString("orchestrator-url")

	fields := strings.Split(strings.ReplaceAll(flagReturnedFields, " ", ""), ",")

	var filter map[string]interface{}
	err := json.Unmarshal([]byte(flagFilter), &filter)
	if err != nil {
		log.Fatalf("error during JSON unmarshalling: %s", err)
	}

	// build our request to the orchestrator using the provided filter and
	// fields
	requestBody, err := json.Marshal(map[string]interface{}{
		"ReturnedFields": fields,
		"Filter":         filter,
	})
	if err != nil {
		log.Fatalf("error during JSON marshalling for request body: %s", err)
	}

	req, err := http.NewRequest("POST", orchestrator+"/results", bytes.NewBuffer(requestBody))
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

	if flagOutputFormat == "json" {
		fmt.Print(string(respBody))
		return
	}

	t := table.NewWriter()
	t.SetOutputMirror(os.Stdout)

	if flagReturnedFields == "*" {
		fields = DefaultReturnedFields
	}

	header := make(table.Row, 0, len(fields))
	for _, field := range fields {
		header = append(header, field)
	}
	t.AppendHeader(header)

	for _, result := range results {
		var row table.Row
		for _, field := range fields {
			v, ok := result[field]
			if !ok {
				log.Fatal("there was an error retrieving results from the map")
			}
			row = append(row, v)
		}
		t.AppendRows([]table.Row{row})
	}

	if flagOutputFormat == "csv" {
		t.RenderCSV()
		return
	}

	t.Render()
}
