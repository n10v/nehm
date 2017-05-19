// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"github.com/bogem/nehm/api"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/downloader"
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/menu"
	"github.com/bogem/nehm/track"
	"github.com/spf13/cobra"
)

var (
	// listCommand is root command for nehm.
	listCommand = &cobra.Command{
		Use:              "nehm",
		Short:            "List likes from your account, download them, set ID3 tags and add them to iTunes",
		Long:             "nehm is a console tool, which downloads, sets ID3 tags (and adds to your iTunes library) your SoundCloud likes in convenient way",
		Run:              showListOfTracks,
		PersistentPreRun: activateVerboseOutput,
	}
)

// activateVerboseOutput activates verbose output, if verbose flag is provided.
func activateVerboseOutput(cmd *cobra.Command, args []string) {
	if verbose {
		logs.EnableInfo()
	}
}

func init() {
	listCommand.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "verbose output")
	addDlFolderFlag(listCommand)
	addItunesPlaylistFlag(listCommand)
	addLimitFlag(listCommand)
	addOffsetFlag(listCommand)
	addPermalinkFlag(listCommand)
}

func showListOfTracks(cmd *cobra.Command, args []string) {
	initializeConfig(cmd)

	logs.FEEDBACK.Println("Getting ID of user")
	config.Set("UID", api.UID(config.Get("permalink")))

	tm := menu.TracksMenu{
		GetTracks: listGetTracks,
		Limit:     limit,
		Offset:    offset,
	}
	downloadTracks := tm.Show()

	downloader.NewConfiguredDownloader().DownloadAll(downloadTracks)
}

func listGetTracks(offset uint) ([]track.Track, error) {
	return api.Favorites(limit, offset, config.Get("UID"))
}
