package applescript

import (
	"io/ioutil"
	"os"
	"os/exec"

	"github.com/bogem/nehm/ui"
)

const (
	addTrackToPlaylistScript = `
		#!/usr/bin/osascript
		on run argv
			set posixFile to first item of argv
			set playlistName to second item of argv

			tell application "iTunes"
				set p to posixFile
				set a to (p as POSIX file)
				add a to playlist playlistName
			end tell
		end run`

	listOfPlaylistsScript = `
		tell application "iTunes"
			get name of playlists
		end tell`
)

type applescriptFile struct {
	Script string
	File   *os.File
}

var (
	addTrackToPlaylistAF = applescriptFile{
		Script: addTrackToPlaylistScript,
	}

	listOfPlaylistsAF = applescriptFile{
		Script: listOfPlaylistsScript,
	}
)

func (af applescriptFile) Filepath() string {
	if af.File == nil {
		af.File = createFile()
		af.writeScriptToFile()
	}
	return af.File.Name()
}

func createFile() *os.File {
	file, err := ioutil.TempFile("", "")
	if err != nil {
		ui.Term(err, "couldn't create file with script")
	}
	return file
}

func (af applescriptFile) writeScriptToFile() {
	if _, err := af.File.Write([]byte(af.Script)); err != nil {
		ui.Term(err, "couldn't write script to file")
	}
}

func AddTrackToPlaylist(trackPath, playlistName string) {
	executeOSAScript(addTrackToPlaylistAF.Filepath(), trackPath, playlistName)
}

func ListOfPlaylists() string {
	return executeOSAScript(listOfPlaylistsAF.Filepath())
}

func executeOSAScript(args ...string) string {
	out, err := exec.Command("osascript", args...).Output()
	if err != nil {
		ui.Term(err, string(out))
	}
	return string(out)
}
