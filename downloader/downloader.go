// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package downloader

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/bogem/id3v2"
	"github.com/bogem/nehm/applescript"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/track"
	"github.com/valyala/fasthttp"
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
		logs.FATAL.Println("there are no tracks to download")
	}

	var errors []string
	// Start with last track.
	for i := len(tracks) - 1; i >= 0; i-- {
		track := tracks[i]
		if err := downloader.Download(track); err != nil {
			errors = append(errors, track.Fullname()+": "+err.Error())
			logs.ERROR.Printf("there was an error while downloading %v: %v\n\n", track.Fullname(), err)
		}
	}

	if len(errors) > 0 && len(tracks) > 1 {
		logs.FEEDBACK.Println("There were errors while downloading tracks:")
		for _, err := range errors {
			logs.FEEDBACK.Println("  " + err)
		}
		logs.FEEDBACK.Println()
	}
}

func (downloader Downloader) Download(t track.Track) error {
	// Download track.
	logs.FEEDBACK.Printf("Downloading %q ...", t.Fullname())
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
		logs.FEEDBACK.Print(" adding to iTunes ...")
		if e := applescript.AddTrackToPlaylist(trackPath, downloader.itunesPlaylist); e != nil {
			err = fmt.Errorf("couldn't add track to playlist: %v", e)
		}
	}

	if err == nil {
		logs.FEEDBACK.Println(" ✔︎")
	} else {
		logs.FEEDBACK.Println(" ✘")
	}

	return err
}

func downloadTrack(t track.Track, path string) error {
	return download(path, t.URL())
}

func downloadArtwork(t track.Track, path string) error {
	return download(path, t.ArtworkURL())
}

func download(path, url string) error {
	logs.DEBUG.Println("Download from %q to %q", url, path)

	// Download content to memory.
	status, body, err := fasthttp.Get(nil, url)
	if err != nil {
		return err
	}
	if status/100 != 2 {
		return fmt.Errorf("unexpected response status: %v", status)
	}

	// Create file.
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	// Write content to file.
	_, err = file.Write(body)
	return err
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
