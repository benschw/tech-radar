VERSION=$(shell git describe --tags)

all: clean deps test build


clean: 
	rm -rf build/ dist/

deps:
	go get github.com/golang/lint/golint
	go get github.com/mitchellh/gox
	go get -u github.com/jteeuwen/go-bindata/...
	wget http://dl.fligl.io/artifacts/tech-radar-ui/tech-radar-ui_latest.tar.gz
	tar xzf tech-radar-ui_latest.tar.gz


test:
	go list ./... | grep -v '/vendor/' | xargs go vet
	go list ./... | grep -v '/vendor/' | xargs go test


build:
	go-bindata -o assets.go dist/
	go build

package:
	mkdir -p build/pkg/latest build/pkg/release
	gox -ldflags "-X main.Version=$(TRAVIS_BUILD_NUMBER)" -output "build/tech-radar_{{.OS}}_{{.Arch}}" -osarch="linux/amd64"
	cp build/tech-radar_linux_amd64 build/tech-radar
	gzip build/tech-radar_linux_amd64
	zip build/tech-radar_linux_amd64_latest.zip build/tech-radar
	mv build/tech-radar_linux_amd64_latest.zip build/pkg/latest/
	cp build/tech-radar_linux_amd64.gz build/pkg/latest/tech-radar_linux_amd64_latest.gz
	cp build/tech-radar_linux_amd64.gz build/pkg/release/tech-radar_linux_amd64_$(VERSION).gz

ci: clean deps test build package

run:
	BIND="0.0.0.0:8000" DB="admin:changeme@tcp(localhost:3306)/techradar?charset=utf8&parseTime=True" ./tech-radar migrate
	BIND="0.0.0.0:8000" DB="admin:changeme@tcp(localhost:3306)/techradar?charset=utf8&parseTime=True" ./tech-radar
