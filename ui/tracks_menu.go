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
	"github.com/bogem/nehm/ui"
	"github.com/fatih/color"
)

var finishSelection bool

// TracksMenu get tracks from GetTracks function, show these tracks in menu
// and adds them to TracksMenu.Selected.
//
// TracksMenu finishes when user pushes 'd' button.
type TracksMenu struct {
	GetTracks func(offset uint) []track.Track
	Limit     uint
	Offset    uint
	Selected  *[]track.Track
}

func (tm TracksMenu) Show() {
	ui.Say("Getting information about tracks")
	tracks := tm.GetTracks(tm.Offset)
	oldOffset := tm.Offset
	for !finishSelection {
		if oldOffset != tm.Offset {
			tracks = tm.GetTracks(tm.Offset)
			oldOffset = tm.Offset
		}
		trackItems := tm.formTrackItems(tracks)
		clearScreen()
		tm.showMenu(trackItems)
	}
}

var trackItems []ui.MenuItem

func (tm *TracksMenu) formTrackItems(tracks []track.Track) []ui.MenuItem {
	if trackItems == nil {
		trackItems = make([]ui.MenuItem, 0, tm.Limit)
	}
	trackItems = trackItems[:0]

	for i, t := range tracks {
		desc := fmt.Sprintf("%v (%v)", t.Fullname(), t.Duration())

		var trackItem ui.MenuItem
		if contains(*tm.Selected, t) {
			trackItem = ui.MenuItem{
				Index: color.GreenString("A"),
				Desc:  desc,
			}
		} else {
			tDup := t
			trackItem = ui.MenuItem{
				Index: strconv.Itoa(i + 1),
				Desc:  desc,
				Run:   func() { *tm.Selected = append(*tm.Selected, tDup) },
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

var controlItems []ui.MenuItem

func (tm *TracksMenu) showMenu(trackItems []ui.MenuItem) {
	if controlItems == nil {
		controlItems = tm.generateControlItems()
	}
	menu := new(ui.Menu)
	menu.AddItems(trackItems)
	menu.AddNewline()
	menu.AddItems(controlItems)
	menu.Show()
}

func (tm *TracksMenu) generateControlItems() []ui.MenuItem {
	return []ui.MenuItem{
		ui.MenuItem{
			Index: "d",
			Desc:  color.GreenString("Download tracks"),
			Run:   func() { finishSelection = true },
		},

		ui.MenuItem{
			Index: "n",
			Desc:  "Next page",
			Run:   func() { tm.Offset += tm.Limit },
		},

		ui.MenuItem{
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
