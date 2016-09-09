package main

import (
	"flag"
	"log"
	"os"

	"github.com/benschw/tech-radar/radar"
	_ "github.com/jteeuwen/go-bindata"
)

func main() {
	dbStr := os.Getenv("DB")
	bind := os.Getenv("BIND")

	if bind == "" {
		bind = "0.0.0.0:8080"
	}

	if dbStr == "" {
		log.Fatal("Database connection string must be set in 'DB' environment variable")
		return
	}

	flag.Parse()

	js, err := Asset("dist/app.js")
	if err != nil {
		log.Fatal(err)
		return
	}
	css, err := Asset("dist/style.css")
	if err != nil {
		log.Fatal(err)
		return
	}

	server, err := radar.NewServer(dbStr, bind, js, css)
	if err != nil {
		log.Fatal(err)
		return
	}

	if flag.NArg() == 1 && flag.Arg(0) == "migrate" {
		log.Printf("Migrating Database")
		err = server.Migrate()
		if err != nil {
			log.Fatal(err)
		}
		return
	}

	server.Run()
}
