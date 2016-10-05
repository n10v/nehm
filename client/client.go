// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package client

import (
	"encoding/json"
	"math"
	"net/url"
	"strconv"

	"github.com/bogem/nehm/track"
	"github.com/bogem/nehm/ui"
)

const (
	tracksLimit    = 150
	soundCloudLink = "http://soundcloud.com/"
)

func Favorites(count, offset uint, uid string) ([]track.Track, error) {
	requestsCount := float64(count) / float64(tracksLimit)
	requestsCount = math.Ceil(requestsCount)

	var limit uint
	var tracks []track.Track
	params := url.Values{}
	for i := uint(0); i < uint(requestsCount); i++ {
		if count < tracksLimit {
			limit = count
		} else {
			limit = tracksLimit
		}
		count -= limit

		params.Set("limit", strconv.Itoa(int(limit)))
		params.Set("offset", strconv.Itoa(int((i*tracksLimit)+offset)))

		bFavs, err := getFavorites(uid, params)
		if err == ErrNotFound {
			break
		}
		if err != nil {
			return nil, err
		}

		var favs []track.Track
		if err := json.Unmarshal(bFavs, &favs); err != nil {
			ui.Term("Could't unmarshal JSON with likes", err)
		}
		tracks = append(tracks, favs...)
	}
	return tracks, nil
}

type JSONUser struct {
	ID int `json:"id"`
}

func UID(permalink string) string {
	params := url.Values{}
	params.Set("url", soundCloudLink+permalink)

	ui.Println("Getting ID of user")
	bUser, err := resolve(params)
	if err != nil {
		ui.Term("There was a problem by resolving an id of user", err)
	}

	var jUser JSONUser
	if err := json.Unmarshal(bUser, &jUser); err != nil {
		ui.Term("Couldn't unmarshall JSON with user object", err)
	}

	return strconv.Itoa(jUser.ID)
}

func Search(query string, limit, offset uint) ([]track.Track, error) {
	params := url.Values{}
	params.Set("q", query)
	params.Set("limit", strconv.Itoa(int(limit)))
	params.Set("offset", strconv.Itoa(int(offset)))

	bFound, err := search(params)
	if err != nil {
		return nil, err
	}

	var found []track.Track
	if err := json.Unmarshal(bFound, &found); err != nil {
		ui.Term("Couldn't unmarshal JSON with search results", err)
	}

	return found, nil
}

func TrackFromURI(uri string) []track.Track {
	params := url.Values{}
	params.Set("url", uri)

	bTrack, err := resolve(params)
	if err == ErrForbidden {
		ui.Term("You haven't got any access to this track", err)
	}
	if err == ErrNotFound {
		ui.Term("You've entered invalid url", err)
	}
	if err != nil {
		ui.Term("Couldn't get track from url", err)
	}

	var t track.Track
	if err := json.Unmarshal(bTrack, &t); err != nil {
		ui.Term("Couldn't unmarshal JSON with track from URL", err)
	}

	return []track.Track{t}
}
