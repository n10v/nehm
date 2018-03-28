// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package api

import (
	"encoding/json"
	"strconv"

	"github.com/bogem/nehm/logs"
	"github.com/bogem/nehm/track"
)

const maxLimit = 200

func Favorites(limit uint, uid string) ([]track.Track, error) {
	p := NewPaginator(FormFavoritesURL(limit, uid))
	return p.NextPage()
}

func AllFavorites(uid string) ([]track.Track, error) {
	p := NewPaginator(FormFavoritesURL(maxLimit, uid))
	tracks := make([]track.Track, 0)

	for !p.OnLastPage() {
		favs, err := p.NextPage()
		tracks = append(tracks, favs...)
		if err == ErrForbidden {
			break
		}
		if err != nil {
			return tracks, err
		}
		if len(favs) == 0 {
			break
		}
	}

	return tracks, nil
}

type JSONUser struct {
	ID int `json:"id"`
}

func UID(permalink string) string {
	query := "url=http://soundcloud.com/" + permalink
	bUser, err := get(formResolveURL(query))
	if err != nil {
		logs.FATAL.Fatalln("there was a problem by resolving an id of user:", err)
	}

	var jUser JSONUser
	if err := json.Unmarshal(bUser, &jUser); err != nil {
		logs.FATAL.Fatalln("couldn't unmarshall JSON with user object:", err)
	}

	return strconv.Itoa(jUser.ID)
}

func TrackFromURL(url string) []track.Track {
	query := "url=" + url
	bTrack, err := get(formResolveURL(query))
	if err == ErrForbidden {
		logs.FATAL.Fatalln("you haven't got any access to this track:", err)
	}
	if err == ErrNotFound {
		logs.FATAL.Fatalln("you've entered invalid url:", err)
	}
	if err != nil {
		logs.FATAL.Fatalln("couldn't get track from url:", err)
	}

	var t track.Track
	if err := json.Unmarshal(bTrack, &t); err != nil {
		logs.FATAL.Fatalln("couldn't unmarshal JSON with track from URL:", err)
	}

	return []track.Track{t}
}
