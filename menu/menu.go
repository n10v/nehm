// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package menu

import (
	"bufio"
	"bytes"
	"os"
	"strings"

	jww "github.com/spf13/jWalterWeatherman"
)

type Menu struct {
	choices map[string]func()
	output  *bytes.Buffer
}

func (m *Menu) AddItems(items ...MenuItem) {
	if m.choices == nil {
		m.choices = make(map[string]func(), len(items))
	}
	if m.output == nil {
		m.output = new(bytes.Buffer)
	}

	for _, item := range items {
		if item.Run != nil {
			m.choices[item.Index] = item.Run
		}
		m.output.WriteString(item.String() + "\n")
	}
}

func (m *Menu) AddNewline() {
	m.AddItems(MenuItem{
		Desc: "",
	})
}

func (m *Menu) Reset() {
	m.choices = make(map[string]func())
	if m.output == nil {
		m.output = new(bytes.Buffer)
	}
	m.output.Reset()
}

func (m Menu) Show() {
	// Add quit note.
	m.output.WriteString("\nCtrl-C to Quit\n")

	// Print all items.
	jww.FEEDBACK.Println(m.output.String())

	// Run choice.
	choose(m.choices)
}

func choose(choices map[string]func()) {
	jww.FEEDBACK.Print("Enter option: ")

	for {
		var index = readInput()
		var chosen = choices[index]
		if chosen != nil {
			chosen()
			break
		} else {
			jww.FEEDBACK.Print("Invalid choice. Please choose the correct option: ")
		}
	}
}

func readInput() string {
	reader := bufio.NewReader(os.Stdin)
	input, _ := reader.ReadString('\n')
	return strings.TrimSpace(input)
}
