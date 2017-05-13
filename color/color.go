// Copyright 2017 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package color

import (
	"os"

	isatty "github.com/mattn/go-isatty"
)

const escape = "\x1b"

// Foreground text colors.
const (
	fgRed     = "31"
	fgGreen   = "32"
	fgYellow  = "33"
	fgBlue    = "34"
	fgMagenta = "35"
	fgCyan    = "36"
)

var noColor = !isatty.IsTerminal(os.Stdout.Fd())

func colorize(code, text string) string {
	if noColor {
		return text
	}
	return format(code) + text + unformat()
}

func format(code string) string {
	return escape + "[" + code + "m"
}

func unformat() string {
	return escape + "[0m"
}

func RedString(text string) string {
	return colorize(fgRed, text)
}

func GreenString(text string) string {
	return colorize(fgGreen, text)
}

func YellowString(text string) string {
	return colorize(fgYellow, text)
}

func BlueString(text string) string {
	return colorize(fgBlue, text)
}

func MagentaString(text string) string {
	return colorize(fgMagenta, text)
}

func CyanString(text string) string {
	return colorize(fgCyan, text)
}
