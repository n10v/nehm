package api

import (
	"encoding/json"
	"errors"

	"github.com/bogem/nehm/track"
)

var (
	ErrLastPage  = errors.New("current page is last")
	ErrFirstPage = errors.New("current page is first")
)

type paginatedResponse struct {
	Collection []track.Track `json:"collection"`
	NextHref   string        `json:"next_href"`
}

type Paginator struct {
	// currentPage corresponds to index of pages.
	// If it's -1, the Paginator was only initialized.
	currentPage int

	nextHref    string
	tracksCache [][]track.Track
}

// NewPaginator returns new paginator.
// It needs only the url to the first page.
// More: https://developers.soundcloud.com/blog/offset-pagination-deprecated.
func NewPaginator(firstPageURL string) *Paginator {
	return &Paginator{currentPage: -1, nextHref: firstPageURL}
}

func getPage(url string) (paginatedResponse, error) {
	pResponse := paginatedResponse{}

	response, err := get(url)
	if err != nil {
		return pResponse, err
	}

	err = json.Unmarshal(response, &pResponse)
	return pResponse, err
}

// NextPage returns tracks on the next page and error, if it occured.
// If p is on last page, it returns ErrLastPage
func (p *Paginator) NextPage() ([]track.Track, error) {
	if p.OnLastPage() {
		return nil, ErrLastPage
	}

	p.currentPage++

	// If p.tracksCache already has tracks of next page, then use them.
	if len(p.tracksCache)-1 >= p.currentPage {
		return p.tracksCache[p.currentPage], nil
	}

	response, err := getPage(p.nextHref)
	if err != nil {
		return nil, err
	}
	p.nextHref = response.NextHref
	p.tracksCache = append(p.tracksCache, response.Collection)
	return response.Collection, nil
}

// OnLastPage checks, if current page is last.
func (p Paginator) OnLastPage() bool {
	return p.nextHref == ""
}

// PrevPage returns tracks on the previous page and error, if it occured.
// If p is on first page, it returns ErrFirstPage
func (p *Paginator) PrevPage() ([]track.Track, error) {
	if p.OnFirstPage() {
		return nil, ErrFirstPage
	}

	p.currentPage--

	if len(p.tracksCache)+1 >= p.currentPage {
		return p.tracksCache[p.currentPage], nil
	}

	// This should never happen!
	return nil, ErrFirstPage
}

// OnFirstPage checks, if current page is first.
func (p Paginator) OnFirstPage() bool {
	return p.currentPage <= 0
}
