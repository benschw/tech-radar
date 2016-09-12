all: clean deps test build


clean: 
	rm -rf tech-radar dist tech-radar-ui_latest.tar.gz*

deps:
	go get -u github.com/jteeuwen/go-bindata/...
	wget http://dl.fligl.io/artifacts/tech-radar-ui/tech-radar-ui_latest.tar.gz
	tar xzf tech-radar-ui_latest.tar.gz


test:
	go vet $(go list ./... | grep -v '/vendor/')
	go test -v $(go list ./... | grep -v '/vendor/')


build:
	go-bindata -o assets.go dist/
	go build


run:
	BIND="0.0.0.0:8000" DB="admin:changeme@tcp(localhost:3306)/techradar?charset=utf8&parseTime=True" ./tech-radar migrate
	BIND="0.0.0.0:8000" DB="admin:changeme@tcp(localhost:3306)/techradar?charset=utf8&parseTime=True" ./tech-radar
