// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package commands

import (
	"github.com/spf13/cobra"
	jww "github.com/spf13/jWalterWeatherman"
)

var (
	versionCommand = &cobra.Command{
		Use:     "version",
		Short:   "nehm's version",
		Aliases: []string{"v"},
		Run:     showVersion,
	}
)

const version = "3.2"

func showVersion(cmd *cobra.Command, args []string) {
	jww.FEEDBACK.Println(version)
}
