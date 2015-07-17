# nehm

*nehm* is a console tool, which downloads, sets IDv3 tags and adds to your iTunes library your SoundCloud posts or likes (also by url) in convenient way

## Installation

**1. First, you should install `taglib` library**

**Mac OS X:**

`brew install taglib`

or

`sudo port install taglib`

**Linux** (depends on your package manager):

Debian/Ubuntu: ` sudo apt-get install libtag1-dev`

Fedora/RHEL: ` sudo yum install taglib-devel`

**2. Then you can install `nehm` gem:**

`gem install nehm`

**That's all!**

## First usage

If you just installed nehm, you should set it up

Write `nehm init` for it

nehm should answer like this:
```
Hello!
Before using the nehm, you should set it up:
Enter a FULL path to desirable download directory (press enter to set it to ...
```

**Now you can use nehm!**
Go to usage for further instructions

## Usage

**!!nehm doesn't add tracks to iTunes library, if you use Linux!!**

* To get (download to download directory, set tags and add to Itunes library) your last like

  `nehm get like`

* To get your last post (last track or repost from your profile)

  `nehm get post`

* To get multiple last posts or likes

  `nehm get 3 posts` or `nehm get 3 likes`

* To just download and set tags any track, you can input

  `nehm dl post` or `nehm dl like` or `nehm dl 3 likes` and etc.

* And of course you can get or download track from url

  `nehm get https://soundcloud.com/nasa/delta-iv-launch`

  or

  `nehm dl https://soundcloud.com/nasa/delta-iv-launch`

* Also, you can configure nehm (change download directory, iTunes directory, permalink)

  `nehm configure`

* For help, just input

  `nehm help`

##FAQ

**Q: What is permalink?**

A: Permalink is the last word in your profile url. Example: for profile url 'soundcloud.com/qwerty' permalink is 'qwerty'

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bogem/nehm.

## Links

My SoundCloud profile: https://soundcloud.com/bogem
