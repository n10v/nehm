// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"runtime"

	"github.com/bogem/nehm/config"
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
	cmd.Flags().StringVarP(&dlFolder, "dl_folder", "f", "", "filesystem path to download folder")

	if runtime.GOOS == "darwin" {
		cmd.Flags().StringVarP(&itunesPlaylist, "itunes_playlist", "i", "", "name of iTunes playlist")
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

func flagChanged(fs *pflag.FlagSet, key string) bool {
	flag := fs.Lookup(key)
	if flag == nil {
		return false
	}
	return flag.Changed
}

// initializeConfig initializes a config file with sensible default configuration flags.
func initializeConfig(cmd *cobra.Command) {
	if flagChanged(cmd.Flags(), "dl_folder") {
		config.Set("dl_folder", dlFolder)
	}
	if flagChanged(cmd.Flags(), "itunes_playlist") {
		config.Set("itunes_playlist", itunesPlaylist)
	}
	if flagChanged(cmd.Flags(), "permalink") {
		config.Set("permalink", permalink)
	}
}
