// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package downloader

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
	jww "github.com/spf13/jWalterWeatherman"
)

type Downloader struct {
	// dist is the folder, where tracks will be downloaded.
	dist string

	// itunesPlaylist is the iTunes playlist, where tracks will be added.
	itunesPlaylist string
}

func NewConfiguredDownloader() *Downloader {
	return &Downloader{
		dist:           config.Get("dlFolder"),
		itunesPlaylist: config.Get("itunesPlaylist"),
	}
}

func (downloader Downloader) DownloadAll(tracks []track.Track) {
	if len(tracks) == 0 {
		jww.FATAL.Println("there are no tracks to download")
	}

	var errors []string
	// Start with last track.
	for i := len(tracks) - 1; i >= 0; i-- {
		track := tracks[i]
		if err := downloader.Download(track); err != nil {
			errors = append(errors, track.Fullname()+": "+err.Error())
			jww.ERROR.Println("there was an error while downloading", track.Fullname()+":", err)
		}
		jww.FEEDBACK.Println()
	}

	if len(errors) > 0 {
		jww.FEEDBACK.Println("There were errors while downloading tracks:")
		for _, err := range errors {
			jww.FEEDBACK.Println("  " + err)
		}
		jww.FEEDBACK.Println()
	}
}

func (downloader Downloader) Download(t track.Track) error {
	// Download track.
	jww.FEEDBACK.Println("Downloading " + t.Fullname())
	trackPath := filepath.Join(downloader.dist, t.Filename())
	if _, e := os.Create(trackPath); e != nil {
		return fmt.Errorf("couldn't create track file: %v", e)
	}
	if e := downloadTrack(t, trackPath); e != nil {
		return fmt.Errorf("couldn't download track: %v", e)
	}

	// err lets us to not prevent the processing of track further.
	// err will only be returned at the end of this function.
	var err error

	// Download artwork.
	artworkFile, e := ioutil.TempFile("", "")
	if e != nil {
		err = fmt.Errorf("couldn't create artwork file: %v", e)
	} else {
		jww.FEEDBACK.Println("Downloading artwork")
		if e = downloadArtwork(t, artworkFile.Name()); e != nil {
			err = fmt.Errorf("couldn't download artwork file: %v", e)
		}

		// Defer deleting artwork.
		defer artworkFile.Close()
		defer os.Remove(artworkFile.Name())
	}

	// Tag track.
	if e := tag(t, trackPath, artworkFile); e != nil {
		err = fmt.Errorf("there was an error while taging track: %v", e)
	}

	// Add to iTunes.
	if downloader.itunesPlaylist != "" {
		jww.FEEDBACK.Println("Adding to iTunes")
		if e := applescript.AddTrackToPlaylist(trackPath, downloader.itunesPlaylist); e != nil {
			err = fmt.Errorf("couldn't add track to playlist: %v", e)
		}
	}

	return err
}

func downloadTrack(t track.Track, path string) error {
	return runDownloadCmd(path, t.URL())
}

func downloadArtwork(t track.Track, path string) error {
	return runDownloadCmd(path, t.ArtworkURL())
}

func runDownloadCmd(path, url string) error {
	cmd := exec.Command("curl", "-#", "-o", path, "-L", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func tag(t track.Track, trackPath string, artwork *os.File) error {
	tag, e := id3v2.Open(trackPath, id3v2.Options{Parse: false})
	if e != nil {
		return e
	}
	defer tag.Close()

	tag.SetArtist(t.Artist())
	tag.SetTitle(t.Title())
	tag.SetYear(t.Year())

	var err error

	if artwork != nil {
		artworkBytes, e := ioutil.ReadAll(artwork)
		if e != nil {
			err = fmt.Errorf("couldn't read artwork file: %v", e)
		} else {
			pic := id3v2.PictureFrame{
				Encoding:    id3v2.ENUTF8,
				MimeType:    "image/jpeg",
				PictureType: id3v2.PTFrontCover,
				Picture:     artworkBytes,
			}
			tag.AddAttachedPicture(pic)
		}
	}

	if e := tag.Save(); e != nil {
		err = fmt.Errorf("couldn't save tag: %v", e)
	}

	return err
}
