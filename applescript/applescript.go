// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package applescript

import (
	"io/ioutil"
	"os"
	"os/exec"

	"github.com/bogem/nehm/ui"
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

func AddTrackToPlaylist(trackPath, playlistName string) {
	executeOSAScript("add_track_to_playlist", trackPath, playlistName)
}

func ListOfPlaylists() string {
	return executeOSAScript("list_of_playlists")
}

func executeOSAScript(commandType string, args ...string) string {
	if scriptFile == nil {
		scriptFile = createFile()
		writeScriptToFile(script, scriptFile)
	}

	commandArgs := []string{scriptFile.Name(), commandType}
	commandArgs = append(commandArgs, args...)

	out, err := exec.Command("osascript", commandArgs...).Output()
	if err != nil {
		ui.Term(err, string(out))
	}
	return string(out)
}

func createFile() *os.File {
	file, err := ioutil.TempFile("", "")
	if err != nil {
		ui.Term(err, "Couldn't create file with script")
	}
	return file
}

func writeScriptToFile(script string, file *os.File) {
	if _, err := file.Write([]byte(script)); err != nil {
		ui.Term(err, "Couldn't write script to file")
	}
}
