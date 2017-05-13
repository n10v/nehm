// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"strconv"
	"strings"

	"github.com/bogem/nehm/api"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/downloader"
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/track"
	"github.com/spf13/cobra"
)

var (
	getCommand = &cobra.Command{
		Use:     "get [number or url]",
		Short:   "Download either inputed count of likes or track from entered url, set tags (and add to your iTunes library)",
		Aliases: []string{"g"},
		Run:     getTracks,
	}
)

func init() {
	addDlFolderFlag(getCommand)
	addItunesPlaylistFlag(getCommand)
	addOffsetFlag(getCommand)
	addPermalinkFlag(getCommand)
}

func getTracks(cmd *cobra.Command, args []string) {
	initializeConfig(cmd)

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
			logs.FATAL.Fatalln(err)
		}
	} else {
		logs.FATAL.Fatalln("you've entered invalid argument. Run 'nehm get --help' for usage.", nil)
	}

	downloader.NewConfiguredDownloader().DownloadAll(downloadTracks)
}

func getLastTracks(count uint) ([]track.Track, error) {
	logs.FEEDBACK.Println("Getting ID of user")
	uid := api.UID(config.Get("permalink"))
	return api.Favorites(count, offset, uid)
}

func isSoundCloudURL(url string) bool {
	return strings.Contains(url, "soundcloud.com")
}

func getTrackFromURL(url string) []track.Track {
	return api.TrackFromURI(url)
}
