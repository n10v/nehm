// Mini-realization of spf13/viper
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
	"github.com/spf13/cast"
	"github.com/spf13/pflag"
)

var (
	configPath = path.Join(os.Getenv("HOME"), ".nehmconfig")
	configHash = make(map[string]interface{})
	flags      = make(map[string]*pflag.Flag)
)

// Get has the behavior of returning the value associated with the first
// place from where it is set. Get will check value in the following order:
// flag, config file.
//
// Get returns an interface. For a specific value use one of the Get____ methods.
func Get(key string) interface{} {
	// from github.com/spf13/viper
	// Copyright © 2014 Steve Francia <spf@spf13.com>.
	//
	// PFlags first
	flag, exists := flags[key]
	if exists && flag.Changed {
		switch flag.Value.Type() {
		case "int", "int8", "int16", "int32", "int64":
			return cast.ToInt(flag.Value.String())
		case "bool":
			return cast.ToBool(flag.Value.String())
		default:
			return flag.Value.String()
		}
	}

	return configHash[key]
}

// GetString returns the value associated with the key as a string.
func GetString(key string) string { return cast.ToString(Get(key)) }

// GetBool returns the value associated with the key as a boolean.
func GetBool(key string) bool { return cast.ToBool(Get(key)) }

// GetInt returns the value associated with the key as an integer.
func GetInt(key string) int { return cast.ToInt(Get(key)) }

// GetPermalink returns the value associated with the key "permalink".
// It guarantees that will be returned non-blank string.
func GetPermalink() string {
	permalink := GetString("permalink")
	if permalink == "" {
		ui.Term(nil, "You didn't set a permalink. Use flag '-f' or set permalink in config file.\nTo know, what is permalink, read FAQ.")
	}
	return permalink
}

// GetPermalink returns the value associated with the key "dl_folder".
// If key "dl_folder" is blank in config, then it returns path to
// home directory.
func GetDLFolder() string {
	dl_folder := GetString("dl_folder")
	if dl_folder == "" {
		ui.Warning("You didn't set a download folder. Tracks will be downloaded to your home directory.")
		return os.Getenv("HOME")
	}
	return dl_folder
}

// GetItunesPlaylist returns the value associated with
// the key "itunes_playlist".
// If the OS of this computer isn't macOS, then it returns blank string.
func GetItunesPlaylist() string {
	playlist := ""
	if runtime.GOOS == "darwin" {
		playlist = GetString("itunes_playlist")

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

// Read will discover and load the config file from disk.
func Read() {
	configFile, err := os.Open(configPath)
	if err == os.ErrNotExist {
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

	if err := yaml.Unmarshal(configData, configHash); err != nil {
		ui.Term(err, "couldn't unmarshal the config file")
	}
}

// Bind a specific key to a pflag (as used by cobra).
func BindPFlag(key string, flag *pflag.Flag) {
	flags[key] = flag
}
