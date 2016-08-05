package commands

import (
	"fmt"
	"strconv"
)

// String
type stringValue string

func newStringValue(val string) *stringValue {
	return (*stringValue)(&val)
}

func (s *stringValue) Set(val string) error {
	*s = stringValue(val)
	return nil
}

func (s *stringValue) Type() string {
	return "string"
}

func (s *stringValue) String() string { return fmt.Sprintf("%s", *s) }

// Uint
type uintValue uint

func newUintValue(val uint) *uintValue {
	return (*uintValue)(&val)
}

func (i *uintValue) Set(s string) error {
	v, err := strconv.ParseUint(s, 0, 64)
	*i = uintValue(v)
	return err
}

func (i *uintValue) Type() string {
	return "uint"
}

func (i *uintValue) String() string { return fmt.Sprintf("%v", *i) }
