<div align="center">
<img src="https://raw.github.com/bogem/nehm/master/Pictures/logo.png" alt="Logo"></img>


<p><b><i>nehm</i></b> is a console tool, which downloads, sets ID3 tags and adds to your iTunes library (if you're using `macOS`) your <b>SoundCloud</b> likes in convenient way.</p>

</div>

---
<div align="center">
<a href="https://www.dropbox.com/s/lvlp0257bzed8be/1list.png" target="_blank"><img src="https://raw.github.com/bogem/nehm/master/Pictures/1list.png" alt="List"></img></a>
<a href="https://www.dropbox.com/s/b3it7u7xrlyioyc/2get.png" target="_blank"><img src="https://raw.github.com/bogem/nehm/master/Pictures/2get.png" alt="Get"></img></a>
<a href="https://www.dropbox.com/s/z1c1djykv60cscm/3search.png" target="_blank"><img src="https://raw.github.com/bogem/nehm/master/Pictures/3search.png" alt="Search"></img></a>
<a href="https://www.dropbox.com/s/4t3y85050u076g4/4help.png" target="_blank"><img src="https://raw.github.com/bogem/nehm/master/Pictures/4help.png" alt="Help"></img></a>

<p><b>(click to zoom)</b></p>

</div>

---

<div align="center">
<h2>DISCLAIMER</h2>

<b><i><p>For personal use only</p>

Nehm developer doesn't responsible for any illegal usage of this program</i></b>
</div>
## Description
`nehm` is a console tool written in `Go`. It can download your likes and search tracks from SoundCloud. All downloaded tracks are ID3 tagged and can be added to iTunes playlist, **if you use `macOS`**.

`nehm` *wasn't tested on Windows machine, so it can be very buggy on it. I'll be very thankful, if you will report any bug.*

*If you have ideas to improve `nehm`, issues and pull requests are always welcome! Also, if you have difficulties with installation/configuration/usage of `nehm`, don't hesitate to write an issue. I will answer as soon as possible.*
## Installation
### Binary installation of latest release
```bash
export OS=macOS # can be 'linux', 'freebsd', 'netbsd', 'openbsd', 'windows'
export ARCH=64bit # can be '32bit', 'arm32', 'arm64'

# prepare for first install and upgrade
mkdir -p /usr/local/bin
rm /usr/local/bin/nehm

# get latest release
mkdir /tmp/nehm
curl -L "https://github.com/bogem/nehm/releases/download/v3.0/nehm-3.0-$OS-$ARCH.tgz" -o /tmp/nehm/nehm.tgz
tar xzf /tmp/nehm/nehm.tgz
mv tmp/nehm/nehm /usr/local/bin
rm -rf tmp/nehm

# test
nehm version
```

### Advanced install
Install via `go` command:

	$ go get -u github.com/bogem/nehm

## Configuration
First of all, you should configure `nehm`:

1. Create a file `.nehmconfig` in your home directory

2. Write in it configuration, i.e. set three variables in YAML format:

`permalink` - permalink of your SoundCloud profile (last word in your profile URL. More in [FAQ](#faq)),

`dl_folder` - filesystem path to download folder, where will be downloaded all tracks,

`itunes_playlist` - name of iTunes playlist, where will be added all tracks *(if you're using `macOS`)*.

#### Example:
```
permalink: bogem
dl_folder: /Users/bogem/Music
itunes_playlist: iPod
```

## Usage Examples

Type `nehm help` to list of all available commands or `nehm help COMMAND` for specific command.

Also commands may be abbreviated to one symbol length. For example, you can input `nehm s` instead of `nehm search`.

#### Get list of likes and download selected

	$ nehm

#### Get list of likes of `nasa`

	$ nehm -p nasa

#### Download last like

	$ nehm get

#### Download last 3 likes

    $ nehm get 3

 #### Download second like and don't add it to iTunes playlist

	$ nehm get -o 1 -i ''

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

## License

MIT
