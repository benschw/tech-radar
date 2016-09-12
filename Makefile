VERSION=$(shell git describe --tags)

all: clean deps test build


clean: 
	rm -rf tech-radar dist tech-radar-ui_latest.tar.gz* dist2 release
	rm -rf tech-radar_linux_amd64_latest.zip tech-radar_linux_amd64.gz

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
	gox -ldflags "-X main.Version=$(TRAVIS_BUILD_NUMBER)" -output "tech-radar_{{.OS}}_{{.Arch}}" -osarch="linux/amd64"
	cp tech-radar_linux_amd64 tech-radar
	gzip tech-radar_linux_amd64
	zip tech-radar_linux_amd64_latest.zip tech-radar
	mkdir -p dist2 release
	cp tech-radar_linux_amd64_latest.zip dist2/
	cp tech-radar_linux_amd64.gz dist2/tech-radar_linux_amd64_latest.gz
	cp tech-radar_linux_amd64.gz release/tech-radar_linux_amd64_$(VERSION).gz

ci: clean deps test build package

run:
	BIND="0.0.0.0:8000" DB="admin:changeme@tcp(localhost:3306)/techradar?charset=utf8&parseTime=True" ./tech-radar migrate
	BIND="0.0.0.0:8000" DB="admin:changeme@tcp(localhost:3306)/techradar?charset=utf8&parseTime=True" ./tech-radar
