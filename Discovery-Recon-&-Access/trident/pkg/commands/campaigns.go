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
	"github.com/spf13/cobra"
)

var campaignCmd = &cobra.Command{
	Use:   "campaign",
	Short: "top-level command for creating, managing and viewing campaigns",
	Long: `used by an operator to manage password-spraying campaigns, with the
	ability to create new campaigns, list ongoing campaigns, and describe 
	specific ongoing campaigns`,
}

func init() {
	rootCmd.AddCommand(campaignCmd)
}
