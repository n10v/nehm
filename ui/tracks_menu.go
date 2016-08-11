// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"

	"github.com/bogem/nehm/track"
	"github.com/fatih/color"
)

// TracksMenu gets tracks from GetTracks function, show these tracks in menu
// and adds selected to TracksMenu.selected.
//
// TracksMenu finishes when user pushes 'd' button.
type TracksMenu struct {
	GetTracks func(offset uint) []track.Track
	Limit     uint
	Offset    uint

	selected          []track.Track
	selectionFinished bool
}

// Show gets tracks from GetTracks function, show these tracks,
// adds selected to TracksMenu.selected and returns them.
func (tm TracksMenu) Show() []track.Track {
	Say("Getting information about tracks")
	tracks := tm.GetTracks(tm.Offset)
	oldOffset := tm.Offset
	for !tm.selectionFinished {
		if oldOffset != tm.Offset {
			tracks = tm.GetTracks(tm.Offset)
			oldOffset = tm.Offset
		}
		trackItems := tm.formTrackItems(tracks)
		clearScreen()
		tm.showMenu(trackItems)
	}
	return tm.selected
}

var trackItems []MenuItem

func (tm *TracksMenu) formTrackItems(tracks []track.Track) []MenuItem {
	if trackItems == nil {
		trackItems = make([]MenuItem, 0, tm.Limit)
	}
	trackItems = trackItems[:0]

	for i, t := range tracks {
		desc := fmt.Sprintf("%v (%v)", t.Fullname(), t.Duration())

		var trackItem MenuItem
		if contains(tm.selected, t) {
			trackItem = MenuItem{
				Index: color.GreenString("A"),
				Desc:  desc,
			}
		} else {
			tDup := t
			trackItem = MenuItem{
				Index: strconv.Itoa(i + 1),
				Desc:  desc,
				Run:   func() { tm.selected = append(tm.selected, tDup) },
			}
		}
		trackItems = append(trackItems, trackItem)
	}
	return trackItems
}

func contains(s []track.Track, t track.Track) bool {
	for _, v := range s {
		if v.ID() == t.ID() {
			return true
		}
	}
	return false
}

func clearScreen() {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cls")
	} else {
		cmd = exec.Command("clear")
	}
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
			Desc:  color.GreenString("Download tracks"),
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
