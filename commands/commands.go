// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"os"
	"runtime"
	"strings"

	"github.com/bogem/nehm/applescript"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/ui"
	"github.com/bogem/nehm/util"
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
)

var RootCmd = listCommand

// Variables used in flags
var (
	limit, offset                       uint
	dlFolder, itunesPlaylist, permalink string
)

func Execute() {
	RootCmd.AddCommand(getCommand)
	RootCmd.AddCommand(searchCommand)
	RootCmd.AddCommand(versionCommand)
	RootCmd.Execute()
}

// addCommonFlags adds common flags related to download tracks.
func addCommonFlags(cmd *cobra.Command) {
	cmd.Flags().StringVarP(&dlFolder, "dlFolder", "f", "", "filesystem path to download folder")

	if runtime.GOOS == "darwin" {
		cmd.Flags().StringVarP(&itunesPlaylist, "itunesPlaylist", "i", "", "name of iTunes playlist")
	}
}

func addLimitFlag(cmd *cobra.Command) {
	cmd.Flags().UintVarP(&limit, "limit", "l", 10, "count of tracks on each page")
}

func addOffsetFlag(cmd *cobra.Command) {
	cmd.Flags().UintVarP(&offset, "offset", "o", 0, "offset relative to first like")
}

func addPermalinkFlag(cmd *cobra.Command) {
	cmd.Flags().StringVarP(&permalink, "permalink", "p", "", "user's permalink")
}

// initializeConfig initializes a config with flags.
func initializeConfig(cmd *cobra.Command) {
	err := config.ReadInConfig()
	if err == config.ErrNotExist {
		ui.Warning("There is no config file. Read README to configure nehm")
	} else {
		ui.Term("", err)
	}

	loadDefaultSettings()

	initializeDlFolder(cmd)
	initializePermalink(cmd)
	if runtime.GOOS == "darwin" {
		initializeItunesPlaylist(cmd)
	}
}

func loadDefaultSettings() {
	config.SetDefault("dlFolder", os.Getenv("HOME"))
	config.SetDefault("itunesPlaylist", "")
}

func flagChanged(fs *pflag.FlagSet, key string) bool {
	flag := fs.Lookup(key)
	if flag == nil {
		return false
	}
	return flag.Changed
}

// initializeDlFolder initializes dlFolder value. If there is no dlFolder
// set up, then dlFolder is set to HOME env variable.
func initializeDlFolder(cmd *cobra.Command) {
	var df string
	if flagChanged(cmd.Flags(), "dlFolder") {
		df = dlFolder
	} else {
		df = config.Get("dlFolder")
	}
	config.Set("dlFolder", util.SanitizePath(df))
}

// initializePermalink initializes permalink value. If there is no permalink
// set up, then program is terminating.
func initializePermalink(cmd *cobra.Command) {
	if flagChanged(cmd.Flags(), "permalink") {
		config.Set("permalink", permalink)
	} else if config.Get("permalink") == "" {
		ui.Term("You didn't set a permalink. Use flag '-p' or set permalink in config file.\nTo know, what is permalink, read FAQ.", nil)
	}
}

// initializeItunesPlaylist initializes itunesPlaylist value. If there is no
// itunesPlaylist set up, then itunesPlaylist set up to blank string. Blank
// string is the sign, what tracks should not to be added to iTunes.
func initializeItunesPlaylist(cmd *cobra.Command) {
	var playlist string
	if flagChanged(cmd.Flags(), "itunesPlaylist") {
		playlist = itunesPlaylist
	} else {
		playlist = config.Get("itunesPlaylist")
	}
	if playlist != "" {
		playlistsList, err := applescript.ListOfPlaylists()
		if err != nil {
			ui.Term("Couldn't get list of playlists", err)
		}
		if !strings.Contains(playlistsList, playlist) {
			ui.Term("Playlist "+playlist+" doesn't exist. Please enter correct name.", nil)
		}
	}
}
