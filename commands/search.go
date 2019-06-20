// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"strings"

	"github.com/bogem/nehm/api"
	"github.com/bogem/nehm/downloader"
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/menu"
	"github.com/spf13/cobra"
)

var (
	searchCommand = &cobra.Command{
		Use:     "search [query]",
		Short:   "Search tracks, show them, download, set tags and add to iTunes.",
		Aliases: []string{"s"},
		Run:     searchAndShowTracks,
	}
)

func init() {
	addDlFolderFlag(searchCommand)
	addItunesPlaylistFlag(searchCommand)
	addLimitFlag(searchCommand)
}

func searchAndShowTracks(cmd *cobra.Command, args []string) {
	logs.FEEDBACK.Println("Loading...")

	initializeConfig(cmd)

	query := strings.Join(args, " ")

	tm := menu.NewTracksMenu(api.FormSearchURL(limit, query))
	downloadTracks := tm.Show()

	downloader.NewConfiguredDownloader().DownloadAll(downloadTracks)
}
