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

func Favorites(count, offset uint, uid string) []track.Track {
	// TODO: If user has more tracks than count
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
		if err == errForbidden {
			ui.Term(nil, "You don't permitted to see these likes")
		}
		if err == errNotFound {
			break
		}
		if err != nil {
			ui.Term(err, "couldn't get your likes")
		}

		var favs []track.Track
		if err := json.Unmarshal(bFavs, &favs); err != nil {
			ui.Term(err, "could't unmarshal JSON with likes")
		}
		tracks = append(tracks, favs...)
	}
	return tracks
}

type JSONUser struct {
	ID int `json:"id"`
}

func UID(permalink string) string {
	params := url.Values{}
	params.Set("url", soundCloudLink+permalink)

	bUser, err := resolve(params)
	if err != nil {
		ui.Term(err, "there was a problem by resolving an id of user")
	}

	var jUser JSONUser
	if err := json.Unmarshal(bUser, &jUser); err != nil {
		ui.Term(err, "couldn't unmarshall JSON with user object")
	}

	return strconv.Itoa(jUser.ID)
}

func Search(query string, limit, offset uint) []track.Track {
	params := url.Values{}
	params.Set("q", query)
	params.Set("limit", strconv.Itoa(int(limit)))
	params.Set("offset", strconv.Itoa(int(offset)))

	bFound, err := search(params)
	if err != nil {
		ui.Term(err, "couldn't get search results")
	}

	var found []track.Track
	if err := json.Unmarshal(bFound, &found); err != nil {
		ui.Term(err, "couldn't unmarshal JSON with search results")
	}

	return found
}

func TrackFromURI(uri string) []track.Track {
	params := url.Values{}
	params.Set("url", uri)

	bTrack, err := resolve(params)
	if err == errForbidden {
		ui.Term(nil, "You haven't got any access to this track")
	}
	if err == errNotFound {
		ui.Term(nil, "You've entered invalid url.")
	}
	if err != nil {
		ui.Term(err, "couldn't get track from url")
	}

	var t track.Track
	if err := json.Unmarshal(bTrack, &t); err != nil {
		ui.Term(err, "couldn't unmarshal JSON with track from URL")
	}

	return []track.Track{t}
}
