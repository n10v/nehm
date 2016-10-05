// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"bytes"
	"sort"
	"strconv"
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

func (m *Menu) AddItems(mis ...MenuItem) {
	m.items = append(m.items, mis...)
}

func (m *Menu) AddNewline() {
	m.AddItems(newlineItem)
}

func (m *Menu) Clear() {
	m.items = m.items[:0]
}

func (m Menu) Show() {
	var choices = make(map[string]func())

	m.AddItems(quitItem)

	output.Reset()

	for _, item := range m.items {
		output.WriteString(item.String() + "\n")
		if item.IsRunnable() {
			choices[item.Index] = item.Run
		}
	}
	Println(output.String())

	choose(choices)
}

func choose(choices map[string]func()) {
	Print("Enter option: ")
	var index = ReadInput()
	var chosen = choices[index]

	Newline()

	for {
		if chosen != nil {
			chosen()
			break
		} else {
			var keys []string
			for k := range choices {
				keys = append(keys, k)
			}
			keys = sortKeys(keys)

			Print("You must choose one of [" + strings.Join(keys, ", ") + "]: ")
			index = ReadInput()
			chosen = choices[index]
		}
	}
}

func sortKeys(keys []string) []string {
	// find numeric keys
	var numKeys []int
	var stringKeys []string
	for _, v := range keys {
		vNum, err := strconv.Atoi(v)
		if err != nil {
			stringKeys = append(stringKeys, v)
			continue
		}
		numKeys = append(numKeys, vNum)
	}

	// sort keys
	sort.IntSlice(numKeys).Sort()
	sort.StringSlice(stringKeys).Sort()

	// convert numeric keys to string
	sNumKeys := make([]string, 0, len(numKeys))
	for _, n := range numKeys {
		sNumKeys = append(sNumKeys, strconv.Itoa(n))
	}

	sorted := make([]string, 0, len(keys))
	sorted = append(sorted, sNumKeys...)
	sorted = append(sorted, stringKeys...)

	return sorted
}
