// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package util

import (
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

const (
	millisecondsInSecond = 1000
	secondsInMinute      = 60
	minutesInHour        = 60
)

func ParseDuration(duration int) (seconds, minutes, hours int) {
	seconds = duration / millisecondsInSecond
	if seconds >= secondsInMinute {
		minutes = seconds / secondsInMinute
		seconds -= minutes * secondsInMinute
	}
	if minutes >= minutesInHour {
		hours = minutes / minutesInHour
		minutes -= hours * minutesInHour
	}
	return
}

func DurationString(seconds, minutes, hours int) (duration string) {
	duration = formatNumber(minutes) + ":" + formatNumber(seconds)
	if hours > 0 {
		duration = formatNumber(hours) + ":" + duration
	}
	return
}

func formatNumber(num int) (formatted string) {
	if num < 10 {
		formatted += "0"
	}
	formatted += strconv.Itoa(num)
	return
}

func SanitizePath(path string) string {
	if strings.HasPrefix(path, "~") {
		path = strings.Replace(path, "~", os.Getenv("HOME"), 1)
	}
	return filepath.Clean(path)
}
