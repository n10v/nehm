// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"bufio"
	"bytes"
	"os"
	"sort"
	"strconv"
	"strings"

	jww "github.com/spf13/jWalterWeatherman"
)

var (
	output bytes.Buffer

	newlineItem = MenuItem{
		Desc: "",
	}
	quitItem = MenuItem{
		Index: "q",
		Desc:  "Quit",
		Run:   func() { os.Exit(0) },
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
	jww.FEEDBACK.Println(output.String())

	choose(choices)
}

func choose(choices map[string]func()) {
	jww.FEEDBACK.Print("Enter option: ")
	var index = readInput()
	var chosen = choices[index]

	jww.FEEDBACK.Println()
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

			jww.FEEDBACK.Printf("You must choose one of [" + strings.Join(keys, ", ") + "]: ")
			index = readInput()
			chosen = choices[index]
		}
	}
}

func readInput() string {
	reader := bufio.NewReader(os.Stdin)
	input, _ := reader.ReadString('\n')
	return strings.TrimSpace(input)
}

// sortKeys sorts strings and ints in keys.
func sortKeys(keys []string) []string {
	// Find numeric keys.
	var intKeys []int
	var stringKeys []string
	for _, key := range keys {
		intKey, err := strconv.Atoi(key)
		if err != nil {
			// It's a string.
			stringKeys = append(stringKeys, key)
		} else {
			// It's an int.
			intKeys = append(intKeys, intKey)
		}
	}

	// Sort keys.
	sort.IntSlice(intKeys).Sort()
	sort.StringSlice(stringKeys).Sort()

	// Return sorted keys.
	sortedKeys := make([]string, 0, len(keys))
	for _, key := range intKeys {
		sortedKeys = append(sortedKeys, strconv.Itoa(key))
	}
	sortedKeys = append(sortedKeys, stringKeys...)

	return sortedKeys
}
