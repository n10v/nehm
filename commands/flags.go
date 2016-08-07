package commands

import (
	"github.com/bogem/nehm/config"
	"github.com/spf13/pflag"
)

var (
	limit, offset uint

	dlFolderFlag = &pflag.Flag{
		Name:      "dl_folder",
		Shorthand: "f",
		Value:     newStringValue(""),
		Usage:     "filesystem path to download folder",
	}

	itunesPlaylistFlag = &pflag.Flag{
		Name:      "itunes_playlist",
		Shorthand: "i",
		Value:     newStringValue(""),
		Usage:     "name of iTunes playlist",
	}

	permalinkFlag = &pflag.Flag{
		Name:      "permalink",
		Shorthand: "p",
		Value:     newStringValue(""),
		Usage:     "user's permalink",
	}

	limitFlag = &pflag.Flag{
		Name:      "limit",
		Shorthand: "l",
		Value:     newUintValueP(10, &limit),
		Usage:     "count of tracks on each page",
	}

	offsetFlag = &pflag.Flag{
		Name:      "offset",
		Shorthand: "o",
		Value:     newUintValueP(0, &offset),
		Usage:     "offset relative to first like",
	}
)

func init() {
	config.BindPFlag("dl_folder", dlFolderFlag)
	config.BindPFlag("itunes_playlist", itunesPlaylistFlag)
	config.BindPFlag("permalink", permalinkFlag)
}
