// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"os"
	"path/filepath"
	"strconv"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/tracksprocessor"
	"github.com/bogem/nehm/ui"
	"github.com/spf13/cobra"
)

var (
	syncCommand = &cobra.Command{
		Use:   "sync",
		Short: "Synchronise your favorites with folder",
		Long:  "This command downloads missing favorites to your folder. You can configure folder with dlFolder flag.",
		Run:   sync,
	}
)

func init() {
	addDlFolderFlag(syncCommand)
	addItunesPlaylistFlag(syncCommand)
	addPermalinkFlag(syncCommand)
}

func sync(cmd *cobra.Command, args []string) {
	initializeConfig(cmd)
	initializePermalink(cmd)

	// Get favorites from user's profile
	ui.Println("Getting favorites")
	permalink := config.Get("permalink")
	favs, err := client.AllFavorites(permalink)
	if err != nil {
		ui.Term("can't get tracks from SoundCloud", err)
	}

	// Get nonexistent tracks in dlFolder
	ui.Println("Check unsynchronised tracks")
	tracks := nonexistentTracks(config.Get("dlFolder"), favs)

	// Download not yet downloaded tracks
	if len(tracks) == 0 {
		ui.Println("Folder is already synchronised with favorites")
		ui.Quit()
	}
	ui.Println("Downloading " + strconv.Itoa(len(tracks)) + " track(s)")
	ui.Println("")
	tracksprocessor.NewConfiguredTracksProcessor().ProcessAll(tracks)

}

// nonexistentTracks returns tracks
// that don't exist in `dir` but are in `tracks`.
func nonexistentTracks(dir string, tracks []track.Track) []track.Track {
	nonexistent := make([]track.Track, 0, len(tracks))

	for _, t := range tracks {
		path := t.Filename()
		if dir != "." {
			path = filepath.Join(dir, t.Filename())
		}
		if _, err := os.Stat(path); os.IsNotExist(err) {
			nonexistent = append(nonexistent, t)
		}
	}

	return nonexistent
}
