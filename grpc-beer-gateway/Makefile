NAME = grpc-beer-gateway

# This requires Bash version >= 4
SHELL:= /usr/bin/env bash -O globstar
# This will work with legacy versions of Bash without globstar
# SHELL:= /usr/bin/env bash

default: build

.PHONY: image
image:
	docker build -t $(NAME) .

.PHONY: build
build: $(NAME)

$(NAME): gen/go/proto/beer.pb.go
	go build 

gen/go/proto/beer.pb.go:
	buf generate

.PHONY: install-grpc-gateway
install-grpc-gateway:
	go install \                                                                                                                                                                                 main !12 ?3
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
		google.golang.org/protobuf/cmd/protoc-gen-go \
		google.golang.org/grpc/cmd/protoc-gen-go-grpc

.PHONY: clean
clean:
	rm -rf gen