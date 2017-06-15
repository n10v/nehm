// Copyright 2017 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package logs

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/bogem/nehm/color"
)

var (
	INFO     = log.New(ioutil.Discard, "", 0)
	WARN     = log.New(os.Stdout, color.YellowString("WARN: "), 0)
	ERROR    = log.New(os.Stderr, color.RedString("ERROR: "), 0)
	FATAL    = log.New(os.Stderr, color.RedString("FATAL ERROR: "), 0)
	FEEDBACK = new(feedback)
)

func EnableInfo() {
	INFO = log.New(os.Stdout, "INFO: ", 0)
}

type feedback struct{}

func (feedback) Print(a ...interface{}) {
	fmt.Print(a...)
}

func (feedback) Println(a ...interface{}) {
	fmt.Println(a...)
}

func (feedback) Printf(format string, a ...interface{}) {
	fmt.Printf(format, a...)
}
