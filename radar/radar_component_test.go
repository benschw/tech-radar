package radar

import (
	"log"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

var server *Server
var client *Client

func init() {

	s, err := NewServer(
		"admin:changeme@tcp(localhost:3306)/test_techradar?charset=utf8&parseTime=True",
		":7000",
		[]byte("Js Content"),
		[]byte("Css Content"),
	)
	if err != nil {
		panic(err)
	}
	server = s
	go server.Run()

	client = &Client{"http://localhost:7000"}

	time.Sleep(100 * time.Millisecond)
}

func setup() {
	server.Migrate()

}
func teardown() {
	server.repo.Db.DropTable(&Marker{})
}

func TestAdd(t *testing.T) {
	// given
	setup()

	// when
	m, err := client.Add(&Marker{Title: "Hello World"})

	// then
	assert.Nil(t, err, "err should be nil")
	found, err := client.Find(m.Id)

	assert.EqualValues(t, m, found, "added marker should match found marker")
	teardown()
}

func TestDelete(t *testing.T) {
	// given
	setup()
	m, err := client.Add(&Marker{Title: "Hello World"})
	assert.Nil(t, err, "err should be nil")

	// when
	err = client.Delete(m.Id)

	// then
	assert.Nil(t, err, "err should be nil")

	_, err = client.Find(m.Id)
	assert.NotNil(t, err, "err shouldn't be nil")

	teardown()
}

func TestSave(t *testing.T) {
	// given
	setup()
	m, err := client.Add(&Marker{Title: "Hello World"})
	assert.Nil(t, err, "err should be nil")

	// when
	m.Title = "Hello Galaxy"
	saved, err := client.Save(&m)

	// then
	assert.Nil(t, err, "err should be nil")

	found, err := client.Find(m.Id)
	assert.Nil(t, err, "err should be nil")
	assert.EqualValues(t, saved, found, "saved marker should match found marker")

	assert.Equal(t, found.Title, "Hello Galaxy", "title should have been updated")

	teardown()
}
func TestFindForQuadrant(t *testing.T) {
	// given
	setup()
	client.Add(&Marker{Title: "Hello World", Mag: 10, Deg: 45})
	client.Add(&Marker{Title: "Hello World", Mag: 10, Deg: 45})
	client.Add(&Marker{Title: "Hello World", Mag: 10, Deg: 100})
	client.Add(&Marker{Title: "Hello World", Mag: 10, Deg: 100})
	client.Add(&Marker{Title: "Hello World", Mag: 10, Deg: 200})
	client.Add(&Marker{Title: "Hello World", Mag: 10, Deg: 300})

	// when
	tr, trErr := client.FindAllForQuadrant("tr")
	tl, tlErr := client.FindAllForQuadrant("tl")
	br, brErr := client.FindAllForQuadrant("br")
	bl, blErr := client.FindAllForQuadrant("bl")

	// then
	assert.Nil(t, trErr, "err should be nil")
	assert.Nil(t, tlErr, "err should be nil")
	assert.Nil(t, blErr, "err should be nil")
	assert.Nil(t, brErr, "err should be nil")

	log.Printf("%+v", tr)
	assert.Equal(t, 2, len(tr), "should be 2 results")
	assert.Equal(t, 2, len(tl), "should be 2 results")
	assert.Equal(t, 1, len(br), "should be 1 results")
	assert.Equal(t, 1, len(bl), "should be 1 results")

	teardown()
}
