// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package api

import (
	"bytes"
	"errors"
	"net/url"
	"strconv"

	"github.com/bogem/nehm/logs"
	"github.com/valyala/fasthttp"
)

const (
	apiURL   = "https://api.soundcloud.com"
	clientID = "11a37feb6ccc034d5975f3f803928a32"
)

var (
	ErrForbidden = errors.New("403 - you're not allowed to see these tracks")
	ErrNotFound  = errors.New("404 - there are no tracks")

	urlBuffer = new(bytes.Buffer)
)

func formResolveURL(query string) string {
	urlBuffer.Reset()
	urlBuffer.WriteString(apiURL)
	urlBuffer.WriteString("/resolve?")
	urlBuffer.WriteString(query)
	return urlBuffer.String()
}

func FormSearchURL(limit uint, query string) string {
	params := url.Values{}
	params.Set("limit", strconv.Itoa(int(limit)))
	params.Set("linked_partitioning", "1")
	params.Set("client_id", "11a37feb6ccc034d5975f3f803928a32")
	params.Set("q", query)

	urlBuffer.Reset()
	urlBuffer.WriteString(apiURL)
	urlBuffer.WriteString("/tracks?")
	urlBuffer.WriteString(params.Encode())
	return urlBuffer.String()
}

func FormFavoritesURL(limit uint, uid string) string {
	params := url.Values{}
	params.Set("limit", strconv.Itoa(int(limit)))
	params.Set("linked_partitioning", "1")
	params.Set("client_id", "11a37feb6ccc034d5975f3f803928a32")

	urlBuffer.Reset()
	urlBuffer.WriteString(apiURL)
	urlBuffer.WriteString("/users/")
	urlBuffer.WriteString(uid)
	urlBuffer.WriteString("/favorites?")
	urlBuffer.WriteString(params.Encode())
	return urlBuffer.String()
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
