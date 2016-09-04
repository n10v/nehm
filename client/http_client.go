// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package client

import (
	"errors"
	"fmt"
	"net/url"

	"github.com/bogem/nehm/ui"
	"github.com/valyala/fasthttp"
)

const (
	apiURL   = "https://api.soundcloud.com"
	clientID = "11a37feb6ccc034d5975f3f803928a32"
)

var errForbidden = errors.New("403 - Forbidden")
var errNotFound = errors.New("404 - Not Found")

func resolve(params url.Values) ([]byte, error) {
	uri := formResolveURI(params)
	return get(uri)
}

func formResolveURI(params url.Values) string {
	addClientID(&params)
	return fmt.Sprintf("%v/resolve?%v", apiURL, params.Encode())
}

func search(params url.Values) ([]byte, error) {
	uri := formSearchURI(params)
	return get(uri)
}

func formSearchURI(params url.Values) string {
	addClientID(&params)
	return fmt.Sprintf("%v/tracks?%v", apiURL, params.Encode())
}

func getFavorites(uid string, params url.Values) ([]byte, error) {
	uri := formFavoritesURI(uid, params)
	return get(uri)
}

func formFavoritesURI(uid string, params url.Values) string {
	addClientID(&params)
	return fmt.Sprintf("%v/users/%v/favorites?%v", apiURL, uid, params.Encode())
}

func addClientID(params *url.Values) {
	params.Set("client_id", clientID)
}

func get(uri string) ([]byte, error) {
	statusCode, body, err := makeGetRequest(uri)
	if err != nil {
		return nil, err
	}
	if err := handleStatusCode(statusCode); err != nil {
		return nil, err
	}
	return body, nil
}

func makeGetRequest(uri string) (int, []byte, error) {
	return fasthttp.Get(nil, uri)
}

func handleStatusCode(statusCode int) error {
	switch {
	case statusCode == 403:
		return errForbidden
	case statusCode == 404:
		return errNotFound
	case statusCode >= 300 && statusCode < 500:
		return fmt.Errorf("invalid response from SoundCloud: %v", statusCode)
	case statusCode >= 500:
		ui.Term("There is a problem by SoundCloud. Please wait a while", nil)
	}
	return nil
}
