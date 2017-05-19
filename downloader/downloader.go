// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package downloader

import (
	"fmt"
	"io"
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
			logs.FEEDBACK.Println(" ✘")
			errors = append(errors, track.Fullname()+": "+err.Error())
			logs.ERROR.Printf("there was an error while downloading %v: %v\n\n", track.Fullname(), err)
		} else {
			logs.FEEDBACK.Println(" ✔︎")
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

// artworkBuf and musicBuf are used for reusing memory when
// download artworks and tracks respectively.
var artworkBuf, musicBuf []byte

func (downloader Downloader) Download(t track.Track) error {
	artworkBuf = artworkBuf[:0]
	musicBuf = musicBuf[:0]

	// Create track file.
	trackPath := filepath.Join(downloader.dist, t.Filename())
	trackFile, e := os.Create(trackPath)
	if e != nil {
		return fmt.Errorf("couldn't create track file: %v", e)
	}

	// err lets us to not prevent the processing of track further.
	// err will only be returned at the end of this function.
	var err error

	logs.DEBUG.Printf("Downloading from %q to %q\n", t.URL(), trackPath)
	logs.DEBUG.Printf("Downloading artwork from %q\n", t.ArtworkURL())
	logs.FEEDBACK.Printf("Downloading %q ...", t.Fullname())

	// Download artwork.
	artworkBuf, e = download(artworkBuf, t.ArtworkURL())
	if e != nil {
		err = fmt.Errorf("couldn't download artwork file: %v", e)
	}

	// Write ID3 tag to trackFile.
	if e := writeTagToWriter(t, trackFile, artworkBuf); e != nil && err == nil {
		err = fmt.Errorf("there was an error while tagging track: %v", e)
	}

	// Download track and write to trackFile.
	musicBuf, e = download(musicBuf, t.URL())
	if e != nil {
		return fmt.Errorf("couldn't download track: %v", e)
	}
	if _, e := trackFile.Write(musicBuf); e != nil {
		return fmt.Errorf("couldn't write track to file: %v", e)
	}

	// Add to iTunes.
	if downloader.itunesPlaylist != "" {
		logs.FEEDBACK.Print(" adding to iTunes ...")
		if e := applescript.AddTrackToPlaylist(trackPath, downloader.itunesPlaylist); e != nil && err == nil {
			err = fmt.Errorf("couldn't add track to playlist: %v", e)
		}
	}

	return err
}

func download(buf []byte, url string) ([]byte, error) {
	status, buf, err := fasthttp.Get(buf, url)
	if err != nil {
		return nil, err
	}
	if status/100 != 2 {
		return nil, fmt.Errorf("unexpected response status: %v", status)
	}
	return buf, nil

}

func writeTagToWriter(t track.Track, w io.Writer, artwork []byte) error {
	tag := id3v2.NewEmptyTag()

	tag.SetArtist(t.Artist())
	tag.SetTitle(t.Title())
	tag.SetYear(t.Year())

	if len(artwork) > 0 {
		pic := id3v2.PictureFrame{
			Encoding:    id3v2.ENUTF8,
			MimeType:    "image/jpeg",
			PictureType: id3v2.PTFrontCover,
			Picture:     artwork,
		}
		tag.AddAttachedPicture(pic)
	}

	_, err := tag.WriteTo(w)
	return err
}
