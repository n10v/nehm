// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package downloader

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sync"

	"github.com/bogem/id3v2"
	"github.com/bogem/nehm/applescript"
	"github.com/bogem/nehm/color"
	"github.com/bogem/nehm/config"
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/track"
	"github.com/valyala/fasthttp"
)

var errRateLimitExceeded = errors.New(`Unfortunately, rate limit is exceeded. Please try tomorrow ¯\_(ツ)_/¯`)

type errorResponse struct {
	errors []interface{}
}

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
		logs.FATAL.Fatalln("there are no tracks to download")
	}

	var errors []string
	// Start with last track.
	for i := len(tracks) - 1; i >= 0; i-- {
		track := tracks[i]
		err := downloader.download(track)
		if err != nil {
			if err == errRateLimitExceeded {
				logs.FEEDBACK.Println()
				logs.FATAL.Fatalln(err)
			}
			errors = append(errors, track.Fullname()+": "+err.Error())
			logs.FEEDBACK.Println("✘")
			logs.ERROR.Printf("error while downloading %q: %v", track.Fullname(), err)
		} else {
			logs.FEEDBACK.Println("✔︎")
		}
	}

	if len(errors) > 0 && len(tracks) > 1 {
		logs.FEEDBACK.Println("\n" + color.RedString("There were errors while downloading tracks:"))
		for _, err := range errors {
			logs.FEEDBACK.Println(err)
		}
		logs.FEEDBACK.Println()
	}
}

// artworks and trackBuf are used for reusing memory while downloading artworks and tracks.
var (
	artworkBuf []byte
	trackBuf   []byte
)

func (downloader Downloader) download(t track.Track) error {
	artworkURL := t.ArtworkURL()
	url := t.URL()

	logs.INFO.Printf("Downloading track from %q\n", url)
	logs.INFO.Printf("Downloading artwork from %q\n", artworkURL)
	logs.FEEDBACK.Printf("Downloading %q ... ", t.Fullname())

	if url == "" {
		return errors.New("track is not downloadable")
	}

	// err lets us to not prevent the processing of track further.
	// err will only be returned at the end of this function.
	var err error

	var e error

	// Parallelize downloading of track and artwork.
	var wg sync.WaitGroup
	wg.Add(1)

	go func() {
		// Download artwork.
		artworkBuf = artworkBuf[:0]
		_, artworkBuf, e = fasthttp.Get(artworkBuf, artworkURL)
		if e != nil {
			err = fmt.Errorf("couldn't download artwork file: %v", e)
		}
		wg.Done()
	}()

	// Download track.
	trackBuf = trackBuf[:0]
	_, trackBuf, e := fasthttp.Get(trackBuf, url)
	if e != nil {
		return fmt.Errorf("couldn't download track: %v", e)
	}

	wg.Wait()

	// Check if rate limit is not exceeded.
	errResp := new(errorResponse)
	if e := json.Unmarshal(trackBuf, errResp); e == nil {
		return errRateLimitExceeded
	}

	// Create track file.
	trackPath := filepath.Join(downloader.dist, t.Filename())
	trackFile, e := os.Create(trackPath)
	if e != nil {
		return fmt.Errorf("couldn't create track file: %v", e)
	}

	// Write ID3 tag to track file.
	if e := writeTagToWriter(t, trackFile, artworkBuf); e != nil {
		return fmt.Errorf("there was an error while tagging track: %v", e)
	}

	// Write track to track file.
	if _, e := trackFile.Write(trackBuf); e != nil {
		return fmt.Errorf("couldn't write track to file: %v", e)
	}

	// Add to iTunes.
	if downloader.itunesPlaylist != "" {
		logs.FEEDBACK.Print("adding to iTunes ... ")
		if e := applescript.AddTrackToPlaylist(trackPath, downloader.itunesPlaylist); e != nil && err == nil {
			err = fmt.Errorf("couldn't add track to playlist: %v", e)
		}
	}

	return err
}

func writeTagToWriter(t track.Track, w io.Writer, artwork []byte) error {
	tag := id3v2.NewEmptyTag()

	tag.SetArtist(t.Artist())
	tag.SetTitle(t.Title())
	tag.SetYear(t.Year())

	if len(artwork) > 0 {
		pic := id3v2.PictureFrame{
			Encoding:    id3v2.EncodingUTF8,
			MimeType:    "image/jpeg",
			PictureType: id3v2.PTFrontCover,
			Picture:     artwork,
		}
		tag.AddAttachedPicture(pic)
	}

	_, err := tag.WriteTo(w)
	return err
}
