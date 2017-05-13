// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

package api

import (
	"bytes"
	"errors"
	"net/url"

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

	uriBuffer = new(bytes.Buffer)
)

func formResolveURI(params url.Values) string {
	params.Set("client_id", clientID)

	uriBuffer.Reset()
	uriBuffer.WriteString(apiURL)
	uriBuffer.WriteString("/resolve?")
	uriBuffer.WriteString(params.Encode())
	return uriBuffer.String()
}

func formSearchURI(params url.Values) string {
	params.Set("client_id", clientID)

	uriBuffer.Reset()
	uriBuffer.WriteString(apiURL)
	uriBuffer.WriteString("/tracks?")
	uriBuffer.WriteString(params.Encode())
	return uriBuffer.String()
}

func formFavoritesURI(uid string, params url.Values) string {
	params.Set("client_id", clientID)

	uriBuffer.Reset()
	uriBuffer.WriteString(apiURL)
	uriBuffer.WriteString("/users/")
	uriBuffer.WriteString(uid)
	uriBuffer.WriteString("/favorites?")
	uriBuffer.WriteString(params.Encode())
	return uriBuffer.String()
}

func get(uri string) ([]byte, error) {
	logs.DEBUG.Println("GET", uri)
	statusCode, body, err := fasthttp.Get(nil, uri)
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
