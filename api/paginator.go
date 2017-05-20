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

	nextHref string
	pages    []string
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

	// If p.pages already has a link to next page, then use it,
	// else append p.nextHref to p.pages.
	if len(p.pages) >= p.currentPage+1 {
		p.nextHref = p.pages[p.currentPage]
	} else if p.nextHref != "" {
		p.pages = append(p.pages, p.nextHref)
	}

	response, err := getPage(p.nextHref)
	if err != nil {
		return nil, err
	}
	p.nextHref = response.NextHref
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

	var url string
	if len(p.pages) >= p.currentPage-1 {
		url = p.pages[p.currentPage]
	} else {
		// This should never happen! :)
		return nil, ErrFirstPage
	}

	response, err := getPage(url)
	if err != nil {
		return nil, err
	}
	return response.Collection, nil
}

// OnFirstPage checks, if current page is first.
func (p Paginator) OnFirstPage() bool {
	return p.currentPage <= 0
}
