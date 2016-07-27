// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"bytes"
	"sort"
	"strings"

	"github.com/fatih/color"
)

var (
	output bytes.Buffer

	newlineItem = MenuItem{
		Desc: "",
	}
	quitItem = MenuItem{
		Index: "q",
		Desc:  color.RedString("Quit"),
		Run:   func() { Quit() },
	}
)

type Menu struct {
	items []MenuItem
}

func (m *Menu) AddItems(mis []MenuItem) {
	m.items = append(m.items, mis...)
}

func (m *Menu) AddItem(mi MenuItem) {
	m.items = append(m.items, mi)
}

func (m *Menu) AddNewline() {
	m.AddItem(newlineItem)
}

func (m Menu) Run() {
	var choices = make(map[string]func())

	m.AddNewline()
	m.AddItem(quitItem)

	output.Reset()

	for _, item := range m.items {
		output.WriteString(item.String() + "\n")
		if item.IsRunnable() {
			choices[item.Index] = item.Run
		}
	}
	Say(output.String())

	m.AddNewline()
	choose(choices)
}

func choose(choices map[string]func()) {
	var index = Ask("Enter option:")
	var chosen = choices[index]

	Newline()

	for {
		if chosen != nil {
			chosen()
			break
		} else {
			keys := make([]string, 0, len(choices))
			for k := range choices {
				keys = append(keys, k)
			}

			sort.StringSlice(keys).Sort()
			index = Ask("You must choose one of [" + strings.Join(keys, ", ") + "] :")
			chosen = choices[index]
		}
	}
}
