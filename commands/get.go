// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"runtime"
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
	getCommand.Flags().AddFlag(offsetFlag)
	getCommand.Flags().AddFlag(dlFolderFlag)
	getCommand.Flags().AddFlag(permalinkFlag)

	if runtime.GOOS == "darwin" {
		getCommand.Flags().AddFlag(itunesPlaylistFlag)
	}
}

func getTracks(cmd *cobra.Command, args []string) {
	var downloadTracks []track.Track
	if len(args) == 0 {
		downloadTracks = getLastTracks(1)
	} else {
		arg := args[0]
		if isSoundCloudURL(arg) {
			downloadTracks = getTrackFromURL(arg)
		} else if num, err := strconv.Atoi(arg); err == nil {
			downloadTracks = getLastTracks(uint(num))
		} else {
			ui.Term(nil, "You've entered invalid argument. Run 'nehm get --help' for usage")
		}
	}

	tracksprocessor.NewConfiguredTracksProcessor().ProcessAll(downloadTracks)
}

func getLastTracks(count uint) []track.Track {
	uid := client.UID(config.GetPermalink())
	return client.Favorites(count, offset, uid)
}

func isSoundCloudURL(url string) bool {
	return strings.Contains(url, "soundcloud.com")
}

func getTrackFromURL(url string) []track.Track {
	return client.TrackFromURI(url)
}
