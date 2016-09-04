// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

// Config is used for reading a config file and flags.
// Inspired from spf13/viper.
package config

import (
	"io/ioutil"
	"os"
	"path"
	"runtime"
	"strings"

	"gopkg.in/yaml.v2"

	"github.com/bogem/nehm/applescript"
	"github.com/bogem/nehm/ui"
	"github.com/bogem/nehm/util"
)

var (
	override = make(map[string]string)
	config   = make(map[string]string)

	configPath = path.Join(os.Getenv("HOME"), ".nehmconfig")
	configRead bool
)

// Get has the behavior of returning the value associated with the first
// place from where it is set. Get will check value in the following order:
// flag, config file.
//
// Get returns a string. For a specific value you can use one of the Get____ methods.
func Get(key string) string {
	if value, exists := override[key]; exists {
		return value
	}

	if !configRead {
		configRead = true
		read()
	}

	return config[key]
}

// read will discover and load the config file from disk.
func read() {
	configFile, err := os.Open(configPath)
	if os.IsNotExist(err) {
		ui.Error(nil, "There is no config file in your home directory")
		return
	}
	if err != nil {
		ui.Term(err, "couldn't open the config file")
	}

	configData, err := ioutil.ReadAll(configFile)
	if err != nil {
		ui.Term(err, "couldn't read the config file")
	}

	if err := yaml.Unmarshal(configData, config); err != nil {
		ui.Term(err, "couldn't unmarshal the config file")
	}
}

// GetPermalink returns the value associated with the key "permalink".
// It guarantees that will be returned non-blank string.
func GetPermalink() string {
	permalink := Get("permalink")
	if permalink == "" {
		ui.Term(nil, "You didn't set a permalink. Use flag '-p' or set permalink in config file.\nTo know, what is permalink, read FAQ.")
	}
	return permalink
}

// GetPermalink returns the value associated with the key "dl_folder".
// If key "dl_folder" is blank in config, then it returns path to
// home directory.
func GetDLFolder() string {
	dlFolder := Get("dlFolder")
	if dlFolder == "" {
		ui.Warning("You didn't set a download folder. Tracks will be downloaded to your home directory.")
		return os.Getenv("HOME")
	}
	return util.CleanPath(dlFolder)
}

// GetItunesPlaylist returns the value associated with
// the key "itunes_playlist".
// If the OS of this computer isn't macOS, then it returns blank string.
func GetItunesPlaylist() string {
	playlist := ""
	if runtime.GOOS == "darwin" {
		playlist = Get("itunesPlaylist")

		if playlist == "" {
			ui.Warning("You didn't set an iTunes playlist. Tracks won't be added to iTunes.")
			return playlist
		}

		playlistsList := applescript.ListOfPlaylists()
		if !strings.Contains(playlistsList, playlist) {
			ui.Term(nil, "Playlist "+playlist+" doesn't exist. Please enter correct name")
		}
	}
	return playlist
}

// Sets the value for the key in the override regiser.
func Set(key, value string) {
	override[key] = value
}
