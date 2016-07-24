package trackprocessor

import (
	"io/ioutil"
	"os"
	"os/exec"
	"path"

	"github.com/bogem/id3v2"
	"github.com/bogem/nehm/applescript"
	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/ui"
)

type TrackProcessor struct {
	DownloadFolder string // In this folder tracks will be downloaded
	ItunesPlaylist string // In this playlist tracks will be added
}

func (tp TrackProcessor) ProcessAll(tracks []track.Track) {
	if len(tracks) == 0 {
		ui.Term(nil, "There are no tracks to download.")
	}
	// Start with last track
	for i := len(tracks) - 1; i >= 0; i-- {
		track := tracks[i]
		tp.Process(track)
		ui.Newline()
	}
	ui.Success("Done!")
	ui.Quit()
}

func (tp TrackProcessor) Process(t track.Track) {
	// Download track
	trackPath := path.Join(tp.DownloadFolder, t.Filename())
	downloadTrack(t, trackPath)

	// Download artwork
	artworkFile, err := ioutil.TempFile("", "")
	if err != nil {
		ui.Term(err, "creation of artwork file failed")
	}
	artworkPath := artworkFile.Name()
	downloadArtwork(t, artworkPath)

	// Tag track
	tag(t, trackPath, artworkFile)

	// Delete artwork
	artworkFile.Close()
	os.Remove(artworkPath)

	// Add to iTunes
	if tp.ItunesPlaylist != "" {
		applescript.AddTrackToPlaylist(trackPath, tp.ItunesPlaylist)
	}
}

func downloadTrack(t track.Track, path string) {
	ui.Say("Downloading " + t.Artist() + " - " + t.Title())
	runDownloadCmd(path, t.URL())
}

func downloadArtwork(t track.Track, path string) {
	ui.Say("Downloading artwork")
	runDownloadCmd(path, t.ArtworkURL())
}

func runDownloadCmd(path, url string) {
	cmd := exec.Command("curl", "-#", "-o", path, "-L", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		ui.Term(err, "download failed")
	}
}

func tag(t track.Track, trackPath string, artworkFile *os.File) {
	tag, err := id3v2.Open(trackPath)
	if err != nil {
		ui.Term(err, "couldn't open track file")
	}

	tag.SetArtist(t.Artist())
	tag.SetTitle(t.Title())
	tag.SetYear(t.Year())

	pic := id3v2.PictureFrame{
		Encoding:    id3v2.ENUTF8,
		MimeType:    "image/jpeg",
		PictureType: id3v2.PTFrontCover,
		Picture:     artworkFile,
	}
	tag.AddAttachedPicture(pic)

	if err := tag.Flush(); err != nil {
		ui.Term(err, "couldn't write tag to file")
	}
}
