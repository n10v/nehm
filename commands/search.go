// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"runtime"
	"strings"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/trackprocessor"
	"github.com/spf13/cobra"
)

var (
	searchCommand = &cobra.Command{
		Use:     "search [query]",
		Short:   "search tracks, show them, download, set tags and add to iTunes",
		Aliases: []string{"s"},
		Run:     searchAndShowTracks,
	}

	searchLimit uint
	searchQuery string
)

func init() {
	searchCommand.Flags().UintVarP(&searchLimit, "limit", "l", 10, "count of tracks on each page")
	searchCommand.Flags().StringP("dl_folder", "f", "", "filesystem path to download folder")

	config.BindPFlag("dl_folder", listCommand.Flags().Lookup("dl_folder"))

	if runtime.GOOS == "darwin" {
		searchCommand.Flags().StringP("itunes_playlist", "i", "", "name of iTunes playlist")
		config.BindPFlag("itunes_playlist", listCommand.Flags().Lookup("itunes_playlist"))
	}
}

func searchAndShowTracks(cmd *cobra.Command, args []string) {
	searchQuery = strings.Join(args, " ")

	config.Read()

	// Get download folder
	dl_folder := config.GetDLFolder()

	// Get iTunes playlist
	itunes_playlist := config.GetItunesPlaylist()

	tp := trackprocessor.TrackProcessor{
		DownloadFolder: dl_folder,
		ItunesPlaylist: itunes_playlist,
	}

	TracksMenu{
		GetTracks:      searchGetTracks,
		Limit:          searchLimit,
		TrackProcessor: tp,
	}.Show()
}

func searchGetTracks(limit, offset uint) []track.Track {
	return client.Search(searchQuery, limit, offset)
}
