// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"time"

	"github.com/bogem/nehm/client"
	"github.com/bogem/nehm/track"
	jww "github.com/spf13/jWalterWeatherman"
)

// TracksMenu gets tracks from GetTracks function, show these tracks in menu
// and returns selected.
//
// TracksMenu finishes when user pushes 'd' button.
type TracksMenu struct {
	GetTracks func(offset uint) ([]track.Track, error)
	Limit     uint
	Offset    uint

	// isSelected holds the ids of selected tracks. With map we can
	// detect really fast if track is selected.
	isSelected map[float64]bool
	// selectedTracks holds selected tracks in initial sequence.
	selectedTracks []track.Track

	selectionFinished bool
}

// Show gets tracks from GetTracks function, show these tracks,
// adds id of selected track to tm.isSelected to detect, what track is selected,
// adds selected to tm.selectedTracks and returns them.
func (tm TracksMenu) Show() []track.Track {
	jww.FEEDBACK.Println("Getting information about tracks")
	tracks, err := tm.GetTracks(tm.Offset)
	if err != nil {
		jww.FATAL.Fatalln(err)
	}
	if len(tracks) == 0 {
		jww.FEEDBACK.Println("There are no tracks to show")
		os.Exit(0)
	}

	oldOffset := tm.Offset

	tm.isSelected = make(map[float64]bool)
	for !tm.selectionFinished {
		if oldOffset != tm.Offset { // If it's new page.
			oldOffset = tm.Offset
			tracks, err = tm.GetTracks(tm.Offset)
			if err != nil {
				jww.ERROR.Println(err)

				// If it's first page or it's unknown error, we should exit.
				if tm.Offset < tm.Limit || !(err == client.ErrForbidden || err == client.ErrNotFound) {
					os.Exit(1)
				}

				jww.FEEDBACK.Println("Downloading previous page")
				time.Sleep(1 * time.Second) // Sleep so user can read the errors.

				tm.Offset -= tm.Limit
				continue
			}
		}

		trackItems := tm.formTrackItems(tracks)
		clearScreen()
		tm.showMenu(trackItems)
	}

	return tm.selectedTracks
}

var trackItems []MenuItem

func (tm *TracksMenu) formTrackItems(tracks []track.Track) []MenuItem {
	if trackItems == nil {
		trackItems = make([]MenuItem, 0, tm.Limit)
	}
	trackItems = trackItems[:0]

	for i, t := range tracks {
		desc := t.Fullname() + " (" + t.Duration() + ")"

		var trackItem MenuItem
		if _, contains := tm.isSelected[t.ID()]; contains {
			trackItem = MenuItem{
				Index: "A",
				Desc:  desc,
			}
		} else {
			t := t // https://golang.org/doc/faq#closures_and_goroutines
			trackItem = MenuItem{
				Index: strconv.Itoa(i + 1),
				Desc:  desc,
				Run: func() {
					tm.isSelected[t.ID()] = true
					tm.selectedTracks = append(tm.selectedTracks, t)
				},
			}
		}
		trackItems = append(trackItems, trackItem)
	}
	return trackItems
}

// clearPath is used for holding the path to clear binary,
// so exec.Command() don't have to always look the path to command.
var clearPath string

func clearScreen() {
	if clearPath == "error" {
		return
	}

	if clearPath == "" {
		var err error
		if runtime.GOOS == "windows" {
			clearPath, err = exec.LookPath("cls")
		} else {
			clearPath, err = exec.LookPath("clear")
		}
		if err != nil { // if there is no clear command, just do not clear the screen ...
			clearPath = "error" // ... and don't check it later
			return
		}
	}

	cmd := exec.Command(clearPath)
	cmd.Stdout = os.Stdout
	cmd.Run()
}

var (
	controlItems []MenuItem
	menu         Menu
)

func (tm *TracksMenu) showMenu(trackItems []MenuItem) {
	if controlItems == nil {
		controlItems = tm.controlItems()
	}
	menu.Clear()
	menu.AddItems(trackItems...)
	menu.AddNewline()
	menu.AddItems(controlItems...)
	menu.Show()
}

func (tm *TracksMenu) controlItems() []MenuItem {
	return []MenuItem{
		MenuItem{
			Index: "d",
			Desc:  "Download tracks",
			Run:   func() { tm.selectionFinished = true },
		},

		MenuItem{
			Index: "n",
			Desc:  "Next page",
			Run:   func() { tm.Offset += tm.Limit },
		},

		MenuItem{
			Index: "p",
			Desc:  "Prev page",
			Run: func() {
				if tm.Offset >= tm.Limit {
					tm.Offset -= tm.Limit
				} else {
					tm.Offset = 0
				}
			},
		},
	}
}
