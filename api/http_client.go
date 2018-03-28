// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package api

import (
	"errors"
	"strconv"

	"github.com/bogem/nehm/logs"
	"github.com/valyala/fasthttp"
)

const (
	apiURL     = "https://api.soundcloud.com"
	clientID   = "11a37feb6ccc034d5975f3f803928a32"
	baseParams = "linked_partitioning=1&client_id=" + clientID
)

var (
	ErrForbidden = errors.New("403 - you're not allowed to see these tracks")
	ErrNotFound  = errors.New("404 - there are no tracks")
)

func formResolveURL(query string) string {
	return apiURL + "/resolve?client_id=" + clientID + "&" + query
}

func FormSearchURL(limit uint, query string) string {
	url := apiURL + "/tracks?" + baseParams
	url += "&limit=" + utoa(limit) + "&q=" + query
	return url
}

func FormFavoritesURL(limit uint, uid string) string {
	url := apiURL + "/users/" + uid + "/favorites?" + baseParams
	url += "&limit=" + utoa(limit)
	return url
}

func get(url string) ([]byte, error) {
	logs.INFO.Println("GET", url)
	statusCode, body, err := fasthttp.Get(nil, url)
	if err != nil {
		return nil, err
	}
	if err := handleStatusCode(statusCode); err != nil {
		return nil, err
	}
	return body, nil
}

func handleStatusCode(statusCode int) error {
	switch {
	case statusCode == 403:
		return ErrForbidden
	case statusCode == 404:
		return ErrNotFound
	case statusCode >= 300 && statusCode < 500:
		logs.FATAL.Fatalln("invalid response from SoundCloud:", statusCode)
	case statusCode >= 500:
		logs.FATAL.Fatalln("there is a problem by SoundCloud. Please wait a while")
	}
	return nil
}

func utoa(u uint) string {
	return strconv.Itoa(int(u))
}
