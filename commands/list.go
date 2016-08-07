// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"runtime"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/tracksprocessor"
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

	listUID string
)

func init() {
	listCommand.Flags().AddFlag(limitFlag)
	listCommand.Flags().AddFlag(offsetFlag)
	listCommand.Flags().AddFlag(dlFolderFlag)
	listCommand.Flags().AddFlag(permalinkFlag)

	if runtime.GOOS == "darwin" {
		listCommand.Flags().AddFlag(itunesPlaylistFlag)
	}
}

func showListOfTracks(cmd *cobra.Command, args []string) {
	listUID = client.UID(config.GetPermalink())

	var downloadTracks []track.Track
	ui.TracksMenu{
		GetTracks: listGetTracks,
		Limit:     limit,
		Offset:    offset,
		Selected:  &downloadTracks,
	}.Show()

	tracksprocessor.NewConfiguredTracksProcessor().ProcessAll(downloadTracks)
}

func listGetTracks(offset uint) []track.Track {
	return client.Favorites(limit, offset, listUID)
}
