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
	"github.com/bogem/nehm/trackprocessor"
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

	getOffset uint
	getUID    string
)

func init() {
	getCommand.Flags().UintVarP(&getOffset, "offset", "o", 0, "offset relative to first like")
	getCommand.Flags().StringP("dl_folder", "f", "", "filesystem path to download folder")
	getCommand.Flags().StringP("permalink", "p", "", "user's permalink")

	config.BindPFlag("dl_folder", getCommand.Flags().Lookup("dl_folder"))
	config.BindPFlag("permalink", getCommand.Flags().Lookup("permalink"))

	if runtime.GOOS == "darwin" {
		getCommand.Flags().StringP("itunes_playlist", "i", "", "name of iTunes playlist")
		config.BindPFlag("itunes_playlist", getCommand.Flags().Lookup("itunes_playlist"))
	}
}

func getTracks(cmd *cobra.Command, args []string) {
	config.Read()

	getUID = client.UID(config.GetPermalink())

	var tracks []track.Track
	if len(args) == 0 {
		tracks = getLastTracks(1)
	} else {
		arg := args[0]
		if isSoundCloudURL(arg) {
			tracks = getTrackFromURL(arg)
		} else if num, err := strconv.Atoi(arg); err == nil {
			tracks = getLastTracks(uint(num))
		} else {
			ui.Term(nil, "You've entered invalid argument. Run 'nehm get --help' for usage")
		}
	}

	// Get download folder
	dl_folder := config.GetDLFolder()

	// Get iTunes playlist
	itunes_playlist := config.GetItunesPlaylist()

	tp := trackprocessor.TrackProcessor{
		DownloadFolder: dl_folder,
		ItunesPlaylist: itunes_playlist,
	}
	tp.ProcessAll(tracks)
}

func getLastTracks(count uint) []track.Track {
	return client.Favorites(count, getOffset, getUID)
}

func isSoundCloudURL(url string) bool {
	return strings.Contains(url, "soundcloud.com")
}

func getTrackFromURL(url string) []track.Track {
	return client.TrackFromURI(url)
}
