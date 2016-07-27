// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package ui

type MenuItem struct {
	Index string
	Desc  string
	Run   func()
}

func (mi MenuItem) IsRunnable() bool {
	return mi.Run != nil
}

func (mi MenuItem) HasIndex() bool {
	return mi.Index != ""
}

func (mi MenuItem) String() string {
	var s string
	if mi.HasIndex() {
		s += mi.Index + " "
	}
	s += mi.Desc

	return s
}
