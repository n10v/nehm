#!/usr/bin/osascript
on run argv
	set posixFile to first item of argv
	set playlistName to second item of argv

	tell application "iTunes"
		set p to posixFile
		set a to (p as POSIX file)
		add a to playlist playlistName
	end tell
end run
