on run argv
	tell application "iTunes"
		set p to first item of argv
		set a to (p as POSIX file)
		add a to playlist (second item of argv)
	end tell
end run
