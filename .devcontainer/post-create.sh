#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date)    post-create start" >> "$HOME/status"

echo "Installing SDK MAN"
# update the repos
#git -C /workspaces/imdb-app pull
#git -C /workspaces/webvalidate pull
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "Done"

echo "Installing Java 17.0.7-zulu"

sdk install java 17.0.7-zulu

echo "Done"

echo "Installing Tilt"

curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

echo "Done"

echo "Installing Buf"

# Check: https://github.com/bufbuild/buf/releases for latest version
BIN="/usr/local/bin" && \
VERSION="1.22.0" && \
sudo curl -sSL \
"https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-$(uname -s)-$(uname -m)" \
-o "${BIN}/buf" && \
sudo chmod +x "${BIN}/buf"

echo "Done"

echo "Installing Golang"

wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz

sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz

rm https://go.dev/dl/go1.20.5.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin

echo "Installed Go Version: "$(go version)

echo "Done"

echo "Executing go install for grpc-gateway"

cd grpc-beer-gateway

go mod tidy

go install \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
    google.golang.org/protobuf/cmd/protoc-gen-go \
    google.golang.org/grpc/cmd/protoc-gen-go-grpc

cd ..

echo "Done"

echo "Updating PATH with Go bin directory"

export PATH="$PATH:$(go env GOPATH)/bin"

echo "Done"

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"