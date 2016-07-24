package commands

var RootCmd = listCommand

func Execute() {
	RootCmd.AddCommand(getCommand)
	RootCmd.AddCommand(searchCommand)
	RootCmd.AddCommand(versionCommand)
	RootCmd.Execute()
}
