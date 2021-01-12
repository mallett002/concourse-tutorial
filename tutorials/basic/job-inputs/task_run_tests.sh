#!/bin/sh

# has access to resource-app (src code to run test against)

set -e

export GOPATH=$(pwd)/gopath:$(pwd)/gopath/src/github.com/cloudfoundry-community/simple-go-web-app/Godeps/_workspace

cd gopath/src/github.com/cloudfoundry-community/simple-go-web-app/

go test ./...
