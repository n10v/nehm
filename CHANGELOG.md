# nehm change log

## 1.5.6.1
* Fix: "execution error: iTunes got an error: file "..." doesn’t understand the “add” message. (-1708)" (thanks to [galaris](https://github.com/galaris) for reporting)
* Fix: nehm fails if track's title has some special characters (thanks to [galaris](https://github.com/galaris) for reporting)

## 1.5.5.2
* Fix wrong detection of artist in title name of song

## 1.5.5.1
* Fix bug with `nil` in user class

## 1.5.5
* Add `version` command
* Some bug fixes for Linux users
* Edit some output messages
* Minor optimizations

## 1.5.4
* Add availability to get/dl 300+ likes and posts
* More convenient CLI
* Fix: nehm fails if you try to get/dl playlist
* Fix: nehm fails if you try to get/dl unstreamable track
* Minor optimizations and bug fixes

## 1.5.3
* Fix bugs, associated with special characters in track's name
* Minor improvements

## 1.5.2
* Binary now works if you use nehm from source
* Minor improvements

## 1.5.1
* Update `nehm help`
  * Fix some descriptions
  * Add `url` option to `dl` and `get`

## 1.5
* Add support for Ruby 1.9.3
* Edit application structure
  * Improve performance when adding tracks to iTunes library
  * Remove useless iTunes path logic
* Prettify `nehm help`

## 1.4.2
* Fix: app fails if you didn't set up playlist (again)
* Reduce gem size

## 1.4.1
* Fix: app fails if you didn't set up playlist

## 1.4
* Now nehm can automatically add track to iTunes playlist. Enter `nehm configure` to set it up
* Also you can download tracks with custom iTunes playlist with `playlist PLAYLIST` feature. See the 'Usage' for instructions
* Handle more errors
* Update `nehm help` command:
  * Add 'Summary' article
  * Convenient read improvements
* Edit warning messages
* Minor improvements and fixes

## 1.3.3
* Add `to current` feature

## 1.3.2
* Add check for no user's posts/likes

## 1.3.1.1
* Minor changes

## 1.3.1
* Edit looped configure menu

## 1.3
* Now you can type short paths to download and iTunes paths while configuring nehm (e.g. ~/Music)
* Configure menu doesn't automatically exit after choose
* nehm doesn't ask for iTunes path by first run

## 1.2.2
* Tracks has got now year tag

## 1.2.1
* Minor technical update

## 1.2
* Add `to PARHTODIRECTORY` feature. See the 'Usage' for instructions
* Improve readability of help
* Add some error checks

## 1.1
* Add `from PERMALINK` feature. See the 'Usage' for instructions

## 1.0.7.1
* Remove useless dependency :)

## 1.0.7
* Add paint dependency

## 1.0.6.1
* Edit gem description
* Edit dependencies

## 1.0.6
* Add check for invalid number of likes/posts
* Add `CHANGELOG.md`
* Use `OPTIONS` instead of `[options]` in help

## 1.0.5
* Fix bundler development dependency

## 1.0.4
* Edit summary in gemspec

## 1.0.3
* Change description of nehm

## 1.0.2
* Edit path to nehm version in Rakefile
* Fix: nehm fails, then setting tags to track

## 1.0.1
* Rakefile:
  * Add push (push to rubygems.org) task
  * Modify tasks
* Edit required Ruby version
* Fix: if you type invalid argument in `nehm get`, then app fails

## 1.0
* First release!
