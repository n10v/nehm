# The project is deprecated

Main reasons of deprecation:
* SoundCloud constantly adding changes to API that complicates development of this app;
* After 6 years of using iTunes, I switched to Spotify. In macOS Catalina iTunes was removed and Apple Music was added. Apple Music on Mac worked really badly in that moment. Actually I like Spotify and almost glad with it.

---

<div align="center">
<img src="https://raw.github.com/bogem/nehm/master/Pictures/logo.png" alt="Logo"></img>

<a href="https://raw.github.com/bogem/nehm/master/Pictures/screen.png" target="_blank">
  <img src="https://raw.github.com/bogem/nehm/master/Pictures/screen.png" alt="Screenshot">
</a>
</div>

## Description
*nehm* is a console tool written in Go. It can download your likes and search tracks from SoundCloud. All downloaded tracks are ID3 tagged.

*nehm wasn't tested on Windows machine, so it can be very buggy on it. I'll be very thankful, if you will report any bug.*

***If you have ideas to improve nehm, issues and pull requests are always welcome! Also, if you have difficulties with installation/configuration/usage of nehm, don't hesitate to write an issue. I will answer as soon as possible.***

## Installation
Install via `go` command:

	$ go get -u github.com/bogem/nehm

or you can download and install binary from [latest release](https://github.com/bogem/nehm/releases).

## Configuration
First of all, you should configure nehm:

1. Create a file `.nehmconfig` in your home directory

2. Write in it configuration, i.e. set three variables in YAML format:

`permalink` - permalink of your SoundCloud profile
(last word in your profile URL.  More in [FAQ](#faq))

`dlFolder` - filesystem path to download folder, where will be downloaded all tracks.
By default, your tracks are being downloaded to your home directory

`itunesPlaylist` - (optional, only for macOS) name of iTunes playlist, where will be added all tracks.
By default, your tracks are **not** being added to iTunes

#### Example:
```
permalink: bogem
dlFolder: /Users/bogem/Music
itunesPlaylist: iPod
```

## Usage Examples

Type `nehm help` to list of all available commands or `nehm help COMMAND` for specific command.

Also commands may be abbreviated to one symbol length. For example, you can input `nehm s` instead of `nehm search`.

#### Get list of likes and download selected

	$ nehm

#### Get list of likes of `nasa`

	$ nehm -p nasa

#### Synchronize your likes with current folder

	$ nehm sync -f . -i ''

#### Download last like

	$ nehm get

#### Download last 3 likes

	$ nehm get 3

#### Download track from URL

	$ nehm get soundcloud.com/nasa/golden-record-russian-greeting

#### Search for tracks and download them

	$ nehm search nasa

## FAQ

**Q: What is permalink?**

**A:** Permalink is the last word in your profile url. **Example:** for profile url ***soundcloud.com/qwerty*** permalink is ***qwerty***

---

**Q: How can I add track to iTunes' music library, but not to any playlist?**

**A:** It depends on language you're using on your Mac. The name of your iTunes' music library you can see here:

![iTunes music master library](https://raw.github.com/bogem/nehm/master/Pictures/music_master_library.png)

For example, english users should use `nehm get -i Music`, russian users - `nehm get -i Музыка`.
