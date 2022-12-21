/*
commit-stream
Author: https://twitter.com/x1sec 
		robert@x1sec.com 

See LICENSE
*/

package commitstream

import (
	"strings"
	//"time"
	"sync"
)

type FilterOptions struct {
	Email               string
	Name                string
	Enabled             bool
	IgnorePrivateEmails bool
}

type commit struct {
	name  string
	email string
	repo  string
}

var mu sync.Mutex

func DoIngest(streamOpt StreamOptions, fo FilterOptions, callback func([]string)) {

	var results = make(chan FeedResult)

	go func() {
		for result := range results {
			for e, n := range result.CommitAuthors {
				c := commit{n, e, result.RepoURL}
				if isMatch(c, fo) {
					outputMatch(c, callback)
				}
			}
		}
	}()

	Run(streamOpt, results)

}

func isMatch(c commit, fo FilterOptions) bool {

	if fo.IgnorePrivateEmails == true {
		if strings.Contains(c.email, "@users.noreply.github.com") {
			return false
		}
	}

	if fo.Enabled == false {
		return true
	}

	result := false

	if fo.Email != "" {
		//fmt.Printf("checking %s against %s\n", email, fo.email)
		for _, e := range strings.Split(fo.Email, ",") {
			if strings.Contains(c.email, strings.TrimSpace(e)) {
				result = true
			}
		}
	}

	if fo.Name != "" {
		for _, n := range strings.Split(fo.Name, ",") {
			if strings.Contains(c.name, strings.TrimSpace(n)) {
				result = true
			}
		}
	}

	return result
}

func outputMatch(c commit, callback func([]string)) {
	s := []string{c.name, c.email, c.repo}
	//tm := time.Now().UTC().Format("2006-01-02T15:04:05")

	mu.Lock()
	callback(s)
	mu.Unlock()
}
