// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"strings"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/tracksprocessor"
	"github.com/bogem/nehm/ui"
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
	addDlFolderFlag(searchCommand)
	addItunesPlaylistFlag(searchCommand)
	addLimitFlag(searchCommand)
}

func searchAndShowTracks(cmd *cobra.Command, args []string) {
	initializeConfig(cmd)

	tp := tracksprocessor.NewConfiguredTracksProcessor()

	searchQuery = strings.Join(args, " ")

	tm := ui.TracksMenu{
		GetTracks: searchGetTracks,
		Limit:     limit,
	}
	downloadTracks := tm.Show()

	tp.ProcessAll(downloadTracks)
}

func searchGetTracks(offset uint) ([]track.Track, error) {
	return client.Search(searchQuery, limit, offset)
}
