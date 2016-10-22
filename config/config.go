// Copyright 2016 Albert Nigmatzianov. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

// Config is used for reading a config file and flags.
// Inspired from spf13/viper.
package config

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"path"

	"gopkg.in/yaml.v2"
)

var (
	override = make(map[string]string)
	config   = make(map[string]string)
	defaults = make(map[string]string)

	configPath = path.Join(os.Getenv("HOME"), ".nehmconfig")

	ErrNotExist = errors.New("config file doesn't exist")
)

// Get has the behavior of returning the value associated with the first
// place from where it is set. Get will check value in the following order:
// flag, config file, defaults.
//
// Get returns a string. For a specific value you can use one of the Get____ methods.
func Get(key string) string {
	if value, exists := override[key]; exists {
		return value
	}
	if value, exists := config[key]; exists {
		return value
	}
	return defaults[key]
}

// ReadInConfig will discover and load the config file from disk.
// It will term the program, if there is an error.
func ReadInConfig() error {
	configFile, err := os.Open(configPath)
	if os.IsNotExist(err) {
		return ErrNotExist
	}
	if err != nil {
		return fmt.Errorf("couldn't open the config file: %v", err)
	}
	defer configFile.Close()

	configData, err := ioutil.ReadAll(configFile)
	if err != nil {
		return fmt.Errorf("couldn't read the config file: %v", err)
	}

	if err := yaml.Unmarshal(configData, config); err != nil {
		return fmt.Errorf("couldn't unmarshal the config file: %v", err)
	}

	return nil
}

// Set sets the value for the key in the override regiser.
func Set(key, value string) {
	override[key] = value
}

// SetDefault sets the value for the key in the default regiser.
func SetDefault(key, value string) {
	defaults[key] = value
}
