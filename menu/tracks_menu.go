// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package menu

import (
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"

	"github.com/bogem/nehm/api"
	"github.com/bogem/nehm/color"
	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/track"
)

func NewTracksMenu(firstPageURL string) *TracksMenu {
	return &TracksMenu{paginator: api.NewPaginator(firstPageURL)}
}

// TracksMenu gets tracks from paginator, shows them in menu
// and returns selected tracks.
//
// TracksMenu finishes when user pushes 'd' button.
type TracksMenu struct {
	paginator *api.Paginator
	tracks    []track.Track
	err       error

	// isSelected holds the ids of selected tracks. With map we can
	// detect really fast if track is selected.
	isSelected map[int]bool
	// selectedTracks holds selected tracks in initial sequence.
	selectedTracks []track.Track

	selectionFinished bool
}

// Show gets tracks from tm.paginator, show these tracks,
// adds id of selected track to tm.isSelected to detect, what track is selected,
// adds selected to tm.selectedTracks and returns them.
func (tm *TracksMenu) Show() []track.Track {
	logs.FEEDBACK.Println("Getting information about tracks")

	tm.getNextPage()
	if tm.err != nil {
		logs.FATAL.Fatalln(tm.err)
	}
	if len(tm.tracks) == 0 {
		logs.FEEDBACK.Println("There are no tracks to show")
		os.Exit(0)
	}

	tm.isSelected = make(map[int]bool)
	for !tm.selectionFinished {
		if tm.err != nil {
			if tm.err == api.ErrLastPage {
				tm.getPrevPage()
				continue
			}
			if tm.err == api.ErrFirstPage {
				tm.getNextPage()
				continue
			}

			logs.ERROR.Println(tm.err)
			logs.FEEDBACK.Print("There was an error. Do you want to download selected tracks before exit? (Y/n): ")
			answer := readInput()
			if strings.EqualFold(answer, "n") {
				os.Exit(1)
			} else {
				break
			}
		}

		trackItems := tm.formTrackItems(tm.tracks)
		clearScreen()
		tm.showMenu(trackItems)
	}

	return tm.selectedTracks
}

var trackItems []MenuItem

func (tm *TracksMenu) formTrackItems(tracks []track.Track) []MenuItem {
	trackItems = trackItems[:0]

	for i, t := range tracks {
		desc := t.Fullname() + " (" + t.Duration() + ")"

		var trackItem MenuItem
		if _, contains := tm.isSelected[t.ID()]; contains {
			trackItem = MenuItem{
				Index: color.GreenString("A"),
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

// clearPath is used for holding the path to 'clear' or 'cls' binary,
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

var menu Menu

func (tm *TracksMenu) showMenu(trackItems []MenuItem) {
	menu.Reset()
	menu.AddItems(trackItems...)
	menu.AddNewline()
	menu.AddItems(tm.controlItems()...)
	menu.Show()
}

func (tm *TracksMenu) controlItems() []MenuItem {
	items := make([]MenuItem, 0, 3)
	items = append(items, MenuItem{
		Index: "d",
		Desc:  "Download tracks",
		Run:   func() { tm.selectionFinished = true },
	})
	if !tm.paginator.OnLastPage() {
		items = append(items, MenuItem{
			Index: "n",
			Desc:  "Next page",
			Run:   func() { tm.getNextPage() },
		})
	}
	if !tm.paginator.OnFirstPage() {
		items = append(items, MenuItem{
			Index: "p",
			Desc:  "Prev page",
			Run:   func() { tm.getPrevPage() },
		})
	}
	return items
}

func (tm *TracksMenu) getNextPage() {
	tm.tracks, tm.err = tm.paginator.NextPage()
}

func (tm *TracksMenu) getPrevPage() {
	tm.tracks, tm.err = tm.paginator.PrevPage()
}
