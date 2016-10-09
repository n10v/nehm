// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"strconv"
	"strings"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/tracksprocessor"
	"github.com/bogem/nehm/ui"
	"github.com/spf13/cobra"
)

var (
	getCommand = &cobra.Command{
		Use:     "get ([number] or [url])",
		Short:   "download either inputed count of likes or track from entered url, set tags (and add to your iTunes library)",
		Aliases: []string{"g"},
		Run:     getTracks,
	}
)

func init() {
	addCommonFlags(getCommand)
	addOffsetFlag(getCommand)
	addPermalinkFlag(getCommand)
}

func getTracks(cmd *cobra.Command, args []string) {
	initializeConfig(cmd)

	tp := tracksprocessor.NewConfiguredTracksProcessor()

	var arg string
	if len(args) == 0 {
		arg = "1"
	} else {
		arg = args[0]
	}

	var downloadTracks []track.Track
	if isSoundCloudURL(arg) {
		downloadTracks = getTrackFromURL(arg)
	} else if num, err := strconv.Atoi(arg); err == nil {
		downloadTracks, err = getLastTracks(uint(num))
		if err != nil {
			handleError(err)
		}
	} else {
		ui.Term("You've entered invalid argument. Run 'nehm get --help' for usage.", nil)
	}

	tp.ProcessAll(downloadTracks)
}

func getLastTracks(count uint) ([]track.Track, error) {
	uid := client.UID(config.GetPermalink())
	return client.Favorites(count, offset, uid)
}

func isSoundCloudURL(url string) bool {
	return strings.Contains(url, "soundcloud.com")
}

func getTrackFromURL(url string) []track.Track {
	return client.TrackFromURI(url)
}

func handleError(err error) {
	switch {
	case strings.Contains(err.Error(), "403"):
		ui.Term("You're not allowed to see these tracks", nil)
	case strings.Contains(err.Error(), "404"):
		ui.Term("There are no tracks", nil)
	}
}
