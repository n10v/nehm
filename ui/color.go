// Copyright 2013 Fatih Arslan. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

import (
	"fmt"
	"strconv"
	"strings"
)

// Color defines a custom color object which is defined by SGR parameters.
type Color struct {
	params []Attribute
}

// Attribute defines a single SGR Code
type Attribute int

const escape = "\x1b"

// Base attributes
const (
	Reset Attribute = iota
)

// Foreground text colors
const (
	FgRed Attribute = iota + 31
	FgGreen
	FgYellow
	FgBlue
	FgMagenta
	FgCyan
)

// New returns a newly created color object.
func New(value ...Attribute) *Color {
	c := &Color{params: make([]Attribute, 0)}
	c.Add(value...)
	return c
}

// Add is used to chain SGR parameters. Use as many as parameters to combine
// and create custom color objects. Example: Add(color.FgRed, color.Underline).
func (c *Color) Add(value ...Attribute) *Color {
	c.params = append(c.params, value...)
	return c
}

// SprintFunc returns a new function that returns colorized strings for the
// given arguments with fmt.Sprint(). Useful to put into or mix into other
// string. Windows users should use this in conjuction with
// mattn/go-colorable package, example:
//
//  output := go-colorable.NewColorableStdout()
//	put := New(FgYellow).SprintFunc()
//	fmt.Fprintf(output, "This is a %s", put("warning"))
func (c *Color) SprintFunc() func(a ...interface{}) string {
	return func(a ...interface{}) string {
		return c.wrap(fmt.Sprint(a...))
	}
}

// wrap wraps the s string with the colors attributes. The string is ready to
// be printed.
func (c *Color) wrap(s string) string {
	return c.format() + s + c.unformat()
}

func (c *Color) format() string {
	return fmt.Sprintf("%s[%sm", escape, c.sequence())
}

func (c *Color) unformat() string {
	return fmt.Sprintf("%s[%dm", escape, Reset)
}

// sequence returns a formated SGR sequence to be plugged into a "\x1b[...m"
// an example output might be: "1;36" -> bold cyan
func (c *Color) sequence() string {
	format := make([]string, len(c.params))
	for i, v := range c.params {
		format[i] = strconv.Itoa(int(v))
	}

	return strings.Join(format, ";")
}

// RedString is an convenient helper function to return a string with red
// foreground.
func RedString(text string) string {
	return New(FgRed).SprintFunc()(text)
}

// GreenString is an convenient helper function to return a string with green
// foreground.
func GreenString(text string) string {
	return New(FgGreen).SprintFunc()(text)
}

// YellowString is an convenient helper function to return a string with yellow
// foreground.
func YellowString(text string) string {
	return New(FgYellow).SprintFunc()(text)
}

// BlueString is an convenient helper function to return a string with blue
// foreground.
func BlueString(text string) string {
	return New(FgBlue).SprintFunc()(text)
}

// MagentaString is an convenient helper function to return a string with magenta
// foreground.
func MagentaString(text string) string {
	return New(FgMagenta).SprintFunc()(text)
}

// CyanString is an convenient helper function to return a string with cyan
// foreground.
func CyanString(text string) string {
	return New(FgCyan).SprintFunc()(text)
}
