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

GO_INSTALL_FILE="go1.20.5.linux-amd64.tar.gz" && \
wget "https://go.dev/dl/${GO_INSTALL_FILE}" && \
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${GO_INSTALL_FILE}  && \
rm ${GO_INSTALL_FILE}

echo "PATH has the following value:"
echo $PATH

echo "Updating PATH"

export PATH=$PATH:/usr/local/go/bin

echo "PATH has the following value now:"
echo $PATH

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

echo "PATH has the following value:"
echo $PATH

echo "Updating PATH with Go bin directory"

export PATH="$PATH:$(go env GOPATH)/bin"

echo "PATH has the following value now:"
echo $PATH

echo "Done"

echo "Installing protobuf-javascript"

wget https://github.com/protocolbuffers/protobuf-javascript/releases/download/v3.21.2/protobuf-javascript-3.21.2-linux-x86_64.tar.gz

sudo tar -C /usr/local -xzf protobuf-javascript-3.21.2-linux-x86_64.tar.gz

rm protobuf-javascript-3.21.2-linux-x86_64.tar.gz

echo "Done"

echo "Installing protoc-gen-grpc-web"

wget https://github.com/grpc/grpc-web/releases/download/1.4.2/protoc-gen-grpc-web-1.4.2-linux-x86_64

sudo mv protoc-gen-grpc-web-1.4.2-linux-x86_64 /usr/local/bin/protoc-gen-grpc-web

chmod +x /usr/local/bin/protoc-gen-grpc-web

echo "Done"

echo "Installing NodeJS + NPM"

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

echo "Done"

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"