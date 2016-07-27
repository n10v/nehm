// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

var RootCmd = listCommand

func Execute() {
	RootCmd.AddCommand(getCommand)
	RootCmd.AddCommand(searchCommand)
	RootCmd.AddCommand(versionCommand)
	RootCmd.Execute()
}
