// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package tracksprocessor

import (
	"errors"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/bogem/id3v2"
	"github.com/bogem/nehm/applescript"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/ui"
)

type TracksProcessor struct {
	DownloadFolder string // In this folder tracks will be downloaded
	ItunesPlaylist string // In this playlist tracks will be added
}

func NewConfiguredTracksProcessor() *TracksProcessor {
	return &TracksProcessor{
		DownloadFolder: config.Get("dlFolder"),
		ItunesPlaylist: config.Get("itunesPlaylist"),
	}
}

func (tp TracksProcessor) ProcessAll(tracks []track.Track) {
	if len(tracks) == 0 {
		ui.Term("There are no tracks to download", nil)
	}
	// Start with last track
	for i := len(tracks) - 1; i >= 0; i-- {
		track := tracks[i]
		if err := tp.Process(track); err != nil {
			ui.Error("There was an error while downloading "+track.Fullname(), err)
			ui.Newline()
			continue
		}
		ui.Newline()
	}
	ui.Success("Done!")
	ui.Quit()
}

func (tp TracksProcessor) Process(t track.Track) error {
	// Download track
	trackPath := filepath.Join(tp.DownloadFolder, t.Filename())
	if _, err := os.Create(trackPath); err != nil {
		return errors.New("couldn't create track file: " + err.Error())
	}
	if err := downloadTrack(t, trackPath); err != nil {
		return errors.New("couldn't download track: " + err.Error())
	}

	// Download artwork
	artworkFile, err := ioutil.TempFile("", "")
	if err != nil {
		return errors.New("couldn't create artwork file: " + err.Error())
	}
	artworkPath := artworkFile.Name()
	if err := downloadArtwork(t, artworkPath); err != nil {
		return errors.New("couldn't download artwork file: " + err.Error())
	}

	// Tag track
	if err := tag(t, trackPath, artworkFile); err != nil {
		return errors.New("coudln't tag file: " + err.Error())
	}

	// Delete artwork
	if err := artworkFile.Close(); err != nil {
		return errors.New("couldn't close artwork file: " + err.Error())
	}
	if err := os.Remove(artworkPath); err != nil {
		return errors.New("couldn't remove artwork file: " + err.Error())
	}

	// Add to iTunes
	if tp.ItunesPlaylist != "" {
		ui.Println("Adding to iTunes")
		if err := applescript.AddTrackToPlaylist(trackPath, tp.ItunesPlaylist); err != nil {
			return errors.New("couldn't add track to playlist: " + err.Error())
		}
	}
	return nil
}

func downloadTrack(t track.Track, path string) error {
	ui.Println("Downloading " + t.Artist() + " - " + t.Title())
	return runDownloadCmd(path, t.URL())
}

func downloadArtwork(t track.Track, path string) error {
	ui.Println("Downloading artwork")
	return runDownloadCmd(path, t.ArtworkURL())
}

func runDownloadCmd(path, url string) error {
	cmd := exec.Command("curl", "-#", "-o", path, "-L", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func tag(t track.Track, trackPath string, artwork io.Reader) error {
	tag, err := id3v2.Open(trackPath)
	if err != nil {
		return err
	}
	defer tag.Close()

	tag.SetArtist(t.Artist())
	tag.SetTitle(t.Title())
	tag.SetYear(t.Year())

	pic := id3v2.PictureFrame{
		Encoding:    id3v2.ENUTF8,
		MimeType:    "image/jpeg",
		PictureType: id3v2.PTFrontCover,
		Picture:     artwork,
	}
	tag.AddAttachedPicture(pic)

	return tag.Save()
}
