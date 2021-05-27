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
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"

	"github.com/praetorian-inc/trident/pkg/db"
)

var pauseCommand = &cobra.Command{
	Use:   "pause",
	Short: "pause campaign execution",
	Long:  `can be used to temporarily pause a running campaign.`,
	Run: func(cmd *cobra.Command, args []string) {
		pausePost(cmd, args)
	},
}

func init() {
	pauseCommand.Flags().UintVarP(&campaignID, "campaign", "c", 0,
		"the identifier of the campaign.")
	err := pauseCommand.MarkFlagRequired("campaign")
	if err != nil {
		log.Fatalf("issue during argument parsing: %s", err)
	}

	campaignCmd.AddCommand(pauseCommand)
}

// pausePost will post the parameters update the Status
// of the campaign specified by the provided ID to CampaignStatusPaused
func pausePost(cmd *cobra.Command, args []string) {
	updateStatus(campaignID, db.CampaignStatusPaused)
}
