// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"github.com/bogem/nehm/ui"
	"github.com/spf13/cobra"
)

var (
	versionCommand = &cobra.Command{
		Use:     "version",
		Short:   "nehm's version",
		Aliases: []string{"v"},
		Run:     showVersion,
	}
)

const version = "3.0.2"

func showVersion(cmd *cobra.Command, args []string) {
	ui.Say(version)
}
