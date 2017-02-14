// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"

	"github.com/bogem/nehm/track"
)

// TracksMenu gets tracks from GetTracks function, show these tracks in menu
// and returns selected.
//
// TracksMenu finishes when user pushes 'd' button.
type TracksMenu struct {
	GetTracks func(offset uint) ([]track.Track, error)
	Limit     uint
	Offset    uint

	selected          map[float64]track.Track
	selectionFinished bool
}

// Show gets tracks from GetTracks function, show these tracks,
// adds selected to TracksMenu.selected and returns them.
func (tm TracksMenu) Show() []track.Track {
	Println("Getting information about tracks")
	tracks, err := tm.GetTracks(tm.Offset)
	if err != nil {
		handleError(err)
		Term("", nil)
	}
	oldOffset := tm.Offset

	if len(tracks) == 0 {
		Term("there are no tracks to show", nil)
	}

	tm.selected = make(map[float64]track.Track)
	for !tm.selectionFinished {
		if oldOffset != tm.Offset {
			oldOffset = tm.Offset
			tracks, err = tm.GetTracks(tm.Offset)
			if err != nil {
				handleError(err)
				if tm.Offset >= tm.Limit {
					Println("Downloading previous page")
					Sleep() // pause the goroutine so user can read the errors
					tm.Offset -= tm.Limit
					continue
				} else {
					Term("", nil)
				}
			}
		}

		trackItems := tm.formTrackItems(tracks)
		clearScreen()
		tm.showMenu(trackItems)
	}

	selected := make([]track.Track, 0, len(tm.selected))
	for _, t := range tm.selected {
		selected = append(selected, t)
	}
	return selected
}

func handleError(err error) {
	switch {
	case strings.Contains(err.Error(), "403"):
		Error("you're not allowed to see these tracks", nil)
	case strings.Contains(err.Error(), "404"):
		Error("there are no tracks", nil)
	default:
		Error("", err)
	}
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
		if _, contains := tm.selected[t.ID()]; contains {
			trackItem = MenuItem{
				Index: GreenString("A"),
				Desc:  desc,
			}
		} else {
			t := t // https://golang.org/doc/faq#closures_and_goroutines
			trackItem = MenuItem{
				Index: strconv.Itoa(i + 1),
				Desc:  desc,
				Run:   func() { tm.selected[t.ID()] = t },
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
	if clearPath == "" {
		var err error
		if runtime.GOOS == "windows" {
			clearPath, err = exec.LookPath("cls")
		} else {
			clearPath, err = exec.LookPath("clear")
		}
		if err != nil { // if there is no clear command, just do not clear the screen
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
			Desc:  GreenString("Download tracks"),
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
