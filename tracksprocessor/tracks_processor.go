// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package tracksprocessor

import (
	"fmt"
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
		ui.Term("there are no tracks to download", nil)
	}

	var errors []string
	// Start with last track
	for i := len(tracks) - 1; i >= 0; i-- {
		track := tracks[i]
		if err := tp.Process(track); err != nil {
			errors = append(errors, track.Fullname()+": "+err.Error())
			ui.Error("there was an error while downloading "+track.Fullname(), err)
		}
		ui.Println("")
	}

	if len(errors) > 0 {
		ui.Println(ui.RedString("There were errors while downloading tracks:"))
		for _, errText := range errors {
			ui.Println(ui.RedString("  " + errText))
		}
		ui.Println("")
	}

	ui.Success("Done!")
	ui.Quit()
}

func (tp TracksProcessor) Process(t track.Track) error {
	// Download track
	ui.Println("Downloading " + t.Artist() + " - " + t.Title())
	trackPath := filepath.Join(tp.DownloadFolder, t.Filename())
	if _, e := os.Create(trackPath); e != nil {
		return fmt.Errorf("couldn't create track file:", e)
	}
	if e := downloadTrack(t, trackPath); e != nil {
		return fmt.Errorf("couldn't download track:", e)
	}

	// err lets us to not prevent the processing of track further.
	var err error

	// Download artwork
	var artworkPath string
	var artworkBytes []byte
	artworkFile, e := ioutil.TempFile("", "")
	if e != nil {
		err = fmt.Errorf("couldn't create artwork file:", e)
	} else {
		artworkPath = artworkFile.Name()
		if e = downloadArtwork(t, artworkPath); e != nil {
			err = fmt.Errorf("couldn't download artwork file:", e)
		}
		if err == nil {
			artworkBytes, e = ioutil.ReadAll(artworkFile)
			if e != nil {
				err = fmt.Errorf("couldn't read artwork file:", e)
			}
		}
	}

	// Tag track
	if e := tag(t, trackPath, artworkBytes); e != nil {
		err = fmt.Errorf("coudln't tag file:", e)
	}

	// Delete artwork
	if e := artworkFile.Close(); e != nil {
		err = fmt.Errorf("couldn't close artwork file:", e)
	}
	if e := os.Remove(artworkPath); e != nil {
		err = fmt.Errorf("couldn't remove artwork file:", e)
	}

	// Add to iTunes
	if tp.ItunesPlaylist != "" {
		ui.Println("Adding to iTunes")
		if e := applescript.AddTrackToPlaylist(trackPath, tp.ItunesPlaylist); e != nil {
			err = fmt.Errorf("couldn't add track to playlist:", e)
		}
	}

	return err
}

func downloadTrack(t track.Track, path string) error {
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

func tag(t track.Track, trackPath string, artwork []byte) error {
	tag, err := id3v2.Open(trackPath)
	if err != nil {
		return err
	}
	defer tag.Close()

	tag.SetArtist(t.Artist())
	tag.SetTitle(t.Title())
	tag.SetYear(t.Year())

	if artwork != nil {
		pic := id3v2.PictureFrame{
			Encoding:    id3v2.ENUTF8,
			MimeType:    "image/jpeg",
			PictureType: id3v2.PTFrontCover,
			Picture:     artwork,
		}
		tag.AddAttachedPicture(pic)
	}

	return tag.Save()
}
