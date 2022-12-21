/*
commit-stream
Author: https://twitter.com/x1sec
		robert@x1sec.com

See LICENSE
*/

package commitstream

import (
	"context"
	"fmt"
	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
	"log"
	"net"
	"os"
	"time"
)

type Session struct {
	client *github.Client
	ctx    context.Context
}

type FeedResult struct {
	CommitAuthors map[string]string
	RepoName      string
	RepoURL       string
	SHA           string
}

type StreamOptions struct {
	AuthToken           string
	SearchAllCommits    bool
	IgnorePrivateEmails bool
	Rate                int
}

func checkResponseError(err error, resp *github.Response) bool {
	if _, ok := err.(*github.RateLimitError); ok {
		log.Println("Hit rate limit. Reset: %s\n", resp.Rate.Reset)
		time.Sleep(time.Until(resp.Rate.Reset.Time))
		return true
	}
	if _, ok := err.(*github.AbuseRateLimitError); ok {
		fmt.Fprintf(os.Stderr, "Abuse detected!\n")
		os.Exit(1)
	}

	if err, ok := err.(net.Error); ok && err.Timeout() {
		fmt.Fprintf(os.Stderr, "Timeout occured, sleeping for 5 seconds...\n")
		time.Sleep(5 * time.Second)
		return true
	}

	if err, r := err.(*github.ErrorResponse); r {
		switch statusCode := err.Response.StatusCode; statusCode {
		case 401:
			fmt.Fprintf(os.Stderr, "401 - Error with authentication token provided.\n")

		case 502:
			// Handle 502 sleeping for file seconds before retrying 
			fmt.Fprintf(os.Stderr, "502 - Bad Gateway, sleeping for 5 seconds... \n")
			time.Sleep(5 * time.Second)
			return true
		default:
			fmt.Fprintf(os.Stderr, err.Error())
		}

		os.Exit(1)
	}

	return false
}

func Run(options StreamOptions, results chan<- FeedResult) {

	var s Session
	s.ctx = context.Background()
	lc, cancel := context.WithCancel(s.ctx)

	defer cancel()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: options.AuthToken},
	)
	tc := oauth2.NewClient(s.ctx, ts)

	s.client = github.NewClient(tc)
	for {
		opt := &github.ListOptions{PerPage: 300}
		for {

			events, resp, err := s.client.Activity.ListEvents(lc, opt)

			if checkResponseError(err, resp) {
				continue
			}

			for _, e := range events {

				if *e.Type == "PushEvent" {
					//fmt.Println(github.Stringify(e))
					var result FeedResult
					result.CommitAuthors = make(map[string]string)

					result.RepoName = *e.GetRepo().Name
					result.RepoURL = "https://github.com/" + result.RepoName
					//result.RepoURL = *e.GetRepo().URL

					p, _ := e.ParsePayload()

					q := p.(*github.PushEvent)

					for _, r := range q.Commits {

						//fmt.Printf("%v\n", github.Stringify(r))
						email := *r.GetAuthor().Email
						name := *r.GetAuthor().Name

						result.CommitAuthors[email] = name
						result.SHA = *r.SHA
						if options.SearchAllCommits == false {
							break
						}
					}
					//fmt.Println(result.CommitAuthors)

					results <- result

				}
			}
			//fmt.Fprintf(os.Stderr, "\r%d/%d remaining\n", resp.Rate.Remaining, resp.Rate.Limit)
			if resp.NextPage == 0 {
				break
			}

			opt.Page = resp.NextPage

			time.Sleep(time.Second * 1)

		}

		time.Sleep(time.Second * time.Duration(options.Rate))

	}
}
