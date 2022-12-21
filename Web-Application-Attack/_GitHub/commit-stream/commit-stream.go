/*
commit-stream
Author: https://twitter.com/x1sec 
		robert@x1sec.com 

See LICENSE
*/

package main

import (
	"encoding/csv"
	"flag"
	"fmt"
	"github.com/x1sec/commit-stream/pkg"
	"os"
)

func printAscii() {
	h := `
 ██████╗ ██████╗ ███╗   ███╗███╗   ███╗██╗████████╗   ███████╗████████╗██████╗ ███████╗ █████╗ ███╗   ███╗
██╔════╝██╔═══██╗████╗ ████║████╗ ████║██║╚══██╔══╝   ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔══██╗████╗ ████║
██║     ██║   ██║██╔████╔██║██╔████╔██║██║   ██║█████╗███████╗   ██║   ██████╔╝█████╗  ███████║██╔████╔██║
██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██║   ██║╚════╝╚════██║   ██║   ██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║
╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║   ██║      ███████║   ██║   ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝   ╚═╝      ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ 
v0.1 - https://github.com/x1sec/commit-stream       

`

	fmt.Fprintf(os.Stderr, h)
}

func init() {
	flag.Usage = func() {
		printAscii()

		h := "Stream Github commit authors in realtime\n\n"

		h += "Usage:\n"
		h += "  commit-stream [OPTIONS]\n\n"

		h += "Options:\n"
		h += "  -e, --email        Match email addresses field (specify multiple with comma). Omit to match all.\n"
		h += "  -n, --name         Match author name field (specify multiple with comma). Omit to match all.\n"
		h += "  -t, --token        Github token (if not specified, will use environment variable 'CSTREAM_TOKEN')\n"
		h += "  -a  --all-commits  Search through previous commit history (default: false)\n"
		h += "  -i  --ignore-priv  Ignore noreply.github.com private email addresses (default: false)\n"
		h += "\n\n"
		fmt.Fprintf(os.Stderr, h)
	}
}

func main() {

	var (
		authToken            string
		filter               commitstream.FilterOptions
		searchAllCommits     bool
	)

	flag.StringVar(&filter.Email, "email", "", "")
	flag.StringVar(&filter.Email, "e", "", "")

	flag.StringVar(&filter.Name, "name", "", "")
	flag.StringVar(&filter.Name, "n", "", "")

	flag.StringVar(&authToken, "token", "", "")
	flag.StringVar(&authToken, "t", "", "")

	flag.BoolVar(&filter.IgnorePrivateEmails, "ignore-priv", false, "")
	flag.BoolVar(&filter.IgnorePrivateEmails, "i", false, "")

	flag.BoolVar(&searchAllCommits, "a", false, "")
	flag.BoolVar(&searchAllCommits, "all-commits", false, "")

	flag.Parse()

	if filter.Email == "" && filter.Name == "" {
		filter.Enabled = false
	} else {
		filter.Enabled = true
	}


	if authToken == "" {
		authToken = os.Getenv("CSTREAM_TOKEN")
		if authToken == "" {
			fmt.Fprintf(os.Stderr, "Please specify Github authentication token with '-t' or by setting the environment variable CSTREAM_TOKEN\n")
			os.Exit(1)
		}
	}

	streamOpt := commitstream.StreamOptions{AuthToken: authToken, SearchAllCommits: searchAllCommits, Rate : 1 }
	commitstream.DoIngest(streamOpt, filter, handleResult)
}

func handleResult(s []string) {
	w := csv.NewWriter(os.Stdout)
	w.Write(s)
	w.Flush()
}
