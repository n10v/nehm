// Copyright 2017 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package logs

import (
	"fmt"
	"log"
	"os"
)

var (
	DEBUG    = log.New(new(emptyWriter), "DEBUG:", 0)
	WARN     = log.New(os.Stdout, "WARN:", 0)
	ERROR    = log.New(os.Stderr, "ERROR:", 0)
	FATAL    = log.New(os.Stderr, "FATAL ERROR:", 0)
	FEEDBACK = new(feedback)

	DebugMode bool
)

func EnableDebug() {
	DEBUG = log.New(os.Stdout, "DEBUG:", 0)
}

type emptyWriter struct{}

func (w emptyWriter) Write(p []byte) (n int, err error) {
	return len(p), nil
}

type feedback struct{}

func (f feedback) Print(a ...interface{}) {
	fmt.Print(a...)
}

func (f feedback) Println(a ...interface{}) {
	fmt.Println(a...)
}

func (f feedback) Printf(format string, a ...interface{}) {
	fmt.Printf(format, a...)
}
