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
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/util"
	"github.com/spf13/cobra"
)

var rootCmd = listCommand

// Variables used in flags.
var (
	limit                               uint
	dlFolder, itunesPlaylist, permalink string
	verbose                             bool
)

func Execute() {
	rootCmd.AddCommand(getCommand)
	rootCmd.AddCommand(searchCommand)
	rootCmd.AddCommand(syncCommand)
	rootCmd.AddCommand(versionCommand)
	rootCmd.Execute()
}

func addDlFolderFlag(cmd *cobra.Command) {
	cmd.Flags().StringVarP(&dlFolder, "dlFolder", "f", "", "filesystem path to download folder")
}

func addItunesPlaylistFlag(cmd *cobra.Command) {
	if runtime.GOOS == "darwin" {
		cmd.Flags().StringVarP(&itunesPlaylist, "itunesPlaylist", "i", "", "name of iTunes playlist")
	}
}

func addLimitFlag(cmd *cobra.Command) {
	cmd.Flags().UintVarP(&limit, "limit", "l", 9, "count of tracks on each page")
}

func addPermalinkFlag(cmd *cobra.Command) {
	cmd.Flags().StringVarP(&permalink, "permalink", "p", "", "user's permalink")
}

// initializeConfig initializes a config with flags.
// It only initializes field if cmd has corresponding flag.
func initializeConfig(cmd *cobra.Command) {
	readInConfig()

	flags := cmd.Flags()
	if flags.Lookup("dlFolder") != nil {
		initializeDlFolder(cmd)
	}
	if flags.Lookup("permalink") != nil {
		initializePermalink(cmd)
	}
	if flags.Lookup("itunesPlaylist") != nil {
		initializeItunesPlaylist(cmd)
	}
}

func readInConfig() {
	err := config.ReadInConfig()
	if err == config.ErrNotExist {
		logs.WARN.Println("there is no config file. Read README to configure nehm")
		return
	}
	if err != nil {
		logs.FATAL.Fatalln(err)
	}
}

// initializeDlFolder initializes dlFolder value. If there is no dlFolder
// set up, then dlFolder is set to HOME env variable.
func initializeDlFolder(cmd *cobra.Command) {
	var df string

	if cmd.Flags().Changed("dlFolder") {
		df = dlFolder
	} else {
		df = config.Get("dlFolder")
	}

	if df == "" {
		logs.WARN.Println("you didn't set a download folder. Tracks will be downloaded to your home directory.")
		df = os.Getenv("HOME")
	}

	config.Set("dlFolder", util.SanitizePath(df))
}

// initializePermalink initializes permalink value. If there is no permalink
// set up, then program is terminating.
func initializePermalink(cmd *cobra.Command) {
	var p string

	if cmd.Flags().Changed("permalink") {
		p = permalink
	} else {
		p = config.Get("permalink")
	}

	if p == "" {
		logs.FATAL.Fatalln("you didn't set a permalink. Use flag '-p' or set permalink in config file.\nTo know, what is permalink, read FAQ.")
	} else {
		config.Set("permalink", p)
	}
}

// initializeItunesPlaylist initializes itunesPlaylist value. If there is no
// itunesPlaylist set up, then itunesPlaylist set up to blank string. Blank
// string is the sign, what tracks should not to be added to iTunes.
//
// initializeItunesPlaylist sets blank string to config, if OS is not darwin.
func initializeItunesPlaylist(cmd *cobra.Command) {
	var playlist string

	if runtime.GOOS == "darwin" {
		if cmd.Flags().Changed("itunesPlaylist") {
			playlist = itunesPlaylist
		} else {
			playlist = config.Get("itunesPlaylist")
		}

		if playlist == "" {
			logs.WARN.Println("you didn't set an iTunes playlist. Tracks won't be added to iTunes.")
		} else {
			playlistsList, err := applescript.ListOfPlaylists()
			if err != nil {
				logs.FATAL.Fatalln("couldn't get list of playlists:", err)
			}
			if !strings.Contains(playlistsList, playlist) {
				logs.FATAL.Fatalf("playlist %q doesn't exist. Please enter correct name.\n", playlist)
			}
		}
	}

	config.Set("itunesPlaylist", playlist)
}
