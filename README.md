# nehm

![ScreenShot](https://raw.github.com/bogem/nehm/master/Screenshots/screenshot.png)

*nehm* is a console tool, which downloads, sets IDv3 tags and adds to your iTunes library your SoundCloud posts or likes in convenient way

[![Gem Version](https://badge.fury.io/rb/nehm.svg)](http://badge.fury.io/rb/nehm)
[![Dependency Status](https://gemnasium.com/bogem/nehm.svg)](https://gemnasium.com/bogem/nehm)
[![Code Climate](https://codeclimate.com/github/bogem/nehm/badges/gpa.svg)](https://codeclimate.com/github/bogem/nehm)

## DISCLAIMER
***For personal use only***

***Nehm developer doesn't responsible for any illegal usage of this program***

## Installation

**1. Install `taglib` library**

**Mac OS X:**

`brew install taglib`

or

`sudo port install taglib`

**Linux:**

Debian/Ubuntu: `sudo apt-get install libtag1-dev`

Fedora/RHEL: `sudo yum install taglib-devel`

**2. Install `nehm` gem:**

`gem install nehm`

## First usage

If you just installed nehm, write any command for its setup

For example, `nehm help`

nehm should answer like this:
```
Hello!
Before using the nehm, you should set it up:
Enter path to desirable download directory (press enter to set it to ...
```

## Usage

**!!nehm doesn't add tracks to iTunes library, if you use Linux!!**

* Get (download to download directory, set tags and add to iTunes library) your last like

  `nehm get like`

* Get your last post (last track or repost from your profile)

  `nehm get post`

   ***(nehm doesn't get and download playlists. It just skips them)***

* Get multiple last posts or likes

  `nehm get 3 posts` or `nehm get 3 likes`

* Just download and set tags any track

  `nehm dl post` or `nehm dl like` or `nehm dl 3 likes`

* Get tracks from another user

  `nehm get post from nasa` or `nehm dl like from bogem`

* Get tracks to another directory

  `nehm get post to ~/Downloads` or `nehm dl like from bogem to .`

* Get tracks to another iTunes playlist

  `nehm get post playlist MyPlaylist`

* Get or download track from url

  `nehm get https://soundcloud.com/nasa/delta-iv-launch`

  or

  `nehm dl https://soundcloud.com/nasa/delta-iv-launch`

* Configure (change download directory, permalink, playlist)

  `nehm configure`

* Help

  `nehm help`

##FAQ

**Q: What is permalink?**

A: Permalink is the last word in your profile url. **Example:** for profile url ***soundcloud.com/qwerty*** permalink is ***qwerty***

## License

MIT License

## Links

My SoundCloud profile: https://soundcloud.com/bogem
