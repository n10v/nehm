// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"time"

	colorable "github.com/mattn/go-colorable"
)

var Output = colorable.NewColorableStdout()

func Error(message string, err error) {
	out := "ERROR: "
	if err == nil {
		out += message
	} else if message == "" {
		out += err.Error()
	} else {
		out += message + ": " + err.Error()
	}
	Println(RedString(out))
}

func Newline() {
	Println("")
}

func Print(s string) {
	fmt.Fprint(Output, s)
}

func Println(s string) {
	Print(s + "\n")
}

func Quit() {
	os.Exit(0)
}

func ReadInput() string {
	reader := bufio.NewReader(os.Stdin)
	input, err := reader.ReadString('\n')
	if err != nil {
		Term("couldn't read the input", err)
	}
	return strings.TrimSpace(input)
}

func Sleep() {
	time.Sleep(2 * time.Second)
}

func Success(s string) {
	Println(GreenString(s))
}

func Term(message string, err error) {
	if message != "" || err != nil {
		Error(message, err)
	}
	os.Exit(1)
}

func Warning(message string) {
	Println(YellowString("WARNING: " + message))
}
