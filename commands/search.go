// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"strings"

	"github.com/bogem/nehm/api"
	"github.com/bogem/nehm/downloader"
	"github.com/bogem/nehm/menu"
	"github.com/bogem/nehm/track"
	"github.com/spf13/cobra"
)

var (
	searchCommand = &cobra.Command{
		Use:     "search [query]",
		Short:   "Search tracks, show them, download, set tags and add to iTunes",
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

	searchQuery = strings.Join(args, " ")

	tm := menu.TracksMenu{
		GetTracks: searchGetTracks,
		Limit:     limit,
	}
	downloadTracks := tm.Show()

	downloader.NewConfiguredDownloader().DownloadAll(downloadTracks)
}

func searchGetTracks(offset uint) ([]track.Track, error) {
	return api.Search(searchQuery, limit, offset)
}
