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

	searchQuery string
)

func init() {
	searchCommand.Flags().AddFlag(limitFlag)
	searchCommand.Flags().AddFlag(dlFolderFlag)

	if runtime.GOOS == "darwin" {
		searchCommand.Flags().AddFlag(itunesPlaylistFlag)
	}
}

func searchAndShowTracks(cmd *cobra.Command, args []string) {
	searchQuery = strings.Join(args, " ")

	config.Read()

	// Get download folder
	dlFolder := config.GetDLFolder()

	// Get iTunes playlist
	itunesPlaylist := config.GetItunesPlaylist()

	tp := trackprocessor.TrackProcessor{
		DownloadFolder: dlFolder,
		ItunesPlaylist: itunesPlaylist,
	}

	TracksMenu{
		GetTracks:      searchGetTracks,
		Limit:          limit,
		TrackProcessor: tp,
	}.Show()
}

func searchGetTracks(offset uint) []track.Track {
	return client.Search(searchQuery, limit, offset)
}
