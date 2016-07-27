// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"runtime"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/trackprocessor"
	"github.com/bogem/nehm/ui"
	"github.com/spf13/cobra"
)

var (
	listCommand = &cobra.Command{
		Use:   "nehm",
		Short: "list of likes from your account, select tracks, download them, set ID3 tags and add them to iTunes",
		Long:  "nehm is a console tool, which downloads, sets ID3 tags (and adds to your iTunes library) your SoundCloud likes in convenient way",
		Run:   showListOfTracks,
	}

	listLimit  uint
	listOffset uint
	listUID    string
)

func init() {
	listCommand.Flags().UintVarP(&listLimit, "limit", "l", 10, "count of tracks on each page")
	listCommand.Flags().UintVarP(&listOffset, "offset", "o", 0, "offset relative to first like")
	listCommand.Flags().StringP("dl_folder", "f", "", "filesystem path to download folder")
	listCommand.Flags().StringP("permalink", "p", "", "user's permalink")

	config.BindPFlag("dl_folder", listCommand.Flags().Lookup("dl_folder"))
	config.BindPFlag("permalink", listCommand.Flags().Lookup("permalink"))

	if runtime.GOOS == "darwin" {
		listCommand.Flags().StringP("itunes_playlist", "i", "", "name of iTunes playlist")
		config.BindPFlag("itunes_playlist", listCommand.Flags().Lookup("itunes_playlist"))
	}
}

func showListOfTracks(cmd *cobra.Command, args []string) {
	config.Read()

	// Get permalink
	ui.Say("Getting ID of user")
	listUID = client.UID(config.GetPermalink())

	// Get download folder
	dl_folder := config.GetDLFolder()

	// Get iTunes playlist
	itunes_playlist := config.GetItunesPlaylist()

	tp := trackprocessor.TrackProcessor{
		DownloadFolder: dl_folder,
		ItunesPlaylist: itunes_playlist,
	}

	TracksMenu{
		GetTracks:      listGetTracks,
		Limit:          listLimit,
		Offset:         listOffset,
		TrackProcessor: tp,
	}.Show()
}

func listGetTracks(limit, offset uint) []track.Track {
	return client.Favorites(limit, offset, listUID)
}
