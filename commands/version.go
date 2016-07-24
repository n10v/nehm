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

const version = "3.0"

func showVersion(cmd *cobra.Command, args []string) {
	ui.Say(version)
}
