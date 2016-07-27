// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package util

import (
	"fmt"
	"strconv"
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
	duration = fmt.Sprintf("%v:%v", formatNumber(minutes), formatNumber(seconds))
	if hours > 0 {
		duration = fmt.Sprintf("%v:%v", formatNumber(hours), duration)
	}
	return
}

func formatNumber(num int) (formated string) {
	if num < 10 {
		formated += "0"
	}
	formated += strconv.Itoa(num)
	return
}
