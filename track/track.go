// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package track

import (
	"runtime"
	"strings"

	"github.com/bogem/nehm/util"
)

const (
	clientID = "11a37feb6ccc034d5975f3f803928a32"
)

type Track struct {
	artist string
	title  string

	// Properties needed for JSON unmarshalling
	JArtworkURL string  `json:"artwork_url"`
	JAuthor     Author  `json:"user"`
	JCreatedAt  string  `json:"created_at"`
	JDuration   float64 `json:"duration"`
	JID         float64 `json:"id"`
	JTitle      string  `json:"title"`
	JURL        string  `json:"stream_url"`
}

func (t *Track) Artist() string {
	if t.artist == "" {
		t.artist, t.title = t.name()
	}
	return t.artist
}

func (t Track) ArtworkURL() string {
	au := t.JArtworkURL
	if au == "" {
		au = t.JAuthor.AvatarURL
	}
	return strings.Replace(au, "large", "t500x500", 1)
}

func (t Track) Duration() string {
	return util.DurationString(util.ParseDuration(int(t.JDuration)))
}

func (t Track) Filename() string {
	// Replace all filesystem non-friendly runes with the underscore
	var toReplace string
	if runtime.GOOS == "windows" {
		toReplace = "<>:\"\\/|?*" // https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
	} else {
		toReplace = ":/\\"
	}
	replaceRunes := func(r rune) rune {
		if strings.ContainsRune(toReplace, r) {
			return '_'
		}
		return r
	}

	return strings.Map(replaceRunes, t.Fullname()) + ".mp3"
}

func (t Track) Fullname() string {
	return t.Artist() + " — " + t.Title()
}

func (t Track) ID() float64 {
	return t.JID
}

// name splits track's title to artist and title if there is one of separators
// in there.
// E.g. if track has title "Michael Jackson - Thriller" then this function will
// return as first string "Michael Jackson" and as second string "Thriller".
func (t Track) name() (string, string) {
	separators := [...]string{" - ", " ~ ", " – "}
	for _, sep := range separators {
		if strings.Contains(t.JTitle, sep) {
			splitted := strings.SplitN(t.JTitle, sep, 2)
			return strings.TrimSpace(splitted[0]), strings.TrimSpace(splitted[1])
		}
	}
	return strings.TrimSpace(t.JAuthor.Username), strings.TrimSpace(t.JTitle)
}

func (t *Track) Title() string {
	if t.title == "" {
		t.artist, t.title = t.name()
	}
	return t.title
}

func (t Track) URL() string {
	return t.JURL + "?client_id=" + clientID
}

func (t Track) Year() string {
	return t.JCreatedAt[0:4]
}
