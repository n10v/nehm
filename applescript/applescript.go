// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package applescript

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
)

const (
	script = `
on run argv
	set commandType to first item of argv as string
	if (commandType is equal to "add_track_to_playlist") then
		add_track_to_playlist(second item of argv, third item of argv)
	end if
	if (commandType is equal to "list_of_playlists") then
		list_of_playlists()
	end if
end run

on add_track_to_playlist(trackPath, playlistName)
	tell application "iTunes"
		add (trackPath as POSIX file) to playlist playlistName
	end tell
end add_track_to_playlist

on list_of_playlists()
	tell application "iTunes"
		get name of playlists
	end tell
end list_of_playlists
`
)

var scriptFile *os.File

func AddTrackToPlaylist(trackPath, playlistName string) error {
	out, err := executeOSAScript("add_track_to_playlist", "./"+trackPath, playlistName)
	if err != nil && out != "" {
		return errors.New(out + ": " + err.Error())
	}
	return err
}

func ListOfPlaylists() (string, error) {
	return executeOSAScript("list_of_playlists")
}

// executeOSAScript executes AppleScript script with args and returns output and error.
func executeOSAScript(args ...string) (string, error) {
	if scriptFile == nil {
		var err error
		scriptFile, err = ioutil.TempFile("", "")
		if err != nil {
			return "", fmt.Errorf("couldn't create osascript file: %v", err)
		}
		if _, err = scriptFile.Write([]byte(script)); err != nil {
			return "", fmt.Errorf("couldn't write script to file: %v", err)
		}
	}

	args = append([]string{scriptFile.Name()}, args...)
	out, err := exec.Command("osascript", args...).CombinedOutput()
	return string(out), err
}
