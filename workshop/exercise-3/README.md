# gRPC REST Gateway

gRPC-Gateway is a plugin of protoc. It reads a gRPC service definition and generates a reverse-proxy server which translates a RESTful JSON API into gRPC. This server is generated according to custom options in your gRPC definition.

![](https://grpc-ecosystem.github.io/grpc-gateway/assets/images/architecture_introduction_diagram.svg)

## gRPC Gateway Installation

To setup your Go environment, follow the instructions found at https://github.com/grpc-ecosystem/grpc-gateway#installation

Note that `go install` will install into `$GOPATH/bin`. In order that `buf` is able to find the installed plugins, make sure that the directory is in `$PATH`. If not, just add it: `export PATH="$PATH:$(go env GOPATH)/bin"`


## Code Generation using Buf

The process of generating the required Go sources from the Proto files is a bit tedious when done by hand or
calling the protoc compiler on the command line. The tool Buf greatly simplifies the process.

First we need to configure Buf with the correct dependencies and proto source roots. Create a file `buf.yaml` in the `grpc-beer-gateway/beerapis` directory with the following content.
```yaml
version: v1
deps:
  # add proto definitions for Google APIs as dependency
  - buf.build/googleapis/googleapis
  # add proto definitions for gRPC gateway as dependency
  - buf.build/grpc-ecosystem/grpc-gateway
```

Run `buf mod update` in the `grpc-beer-gateway/beerapis` directory, which generates a buf.lock file.

Next we need to configure the different protoc plugins used to generate the required Go source files as well as an OpenAPIv2 definition of the REST interface. Create a file `buf.gen.yaml` in the `grpc-beer-gateway/` directory with the following content. 
```yaml
version: v1
plugins:
  - name: go
    out: gen/go
    opt: paths=source_relative
  - name: go-grpc
    out: gen/go
    opt: paths=source_relative
  - name: grpc-gateway
    out: gen/go
    opt:
      - paths=source_relative
      - generate_unbound_methods=true
  - name: openapiv2
    out: gen/openapiv2
```
Also create a file `buf.work.yaml` with the following content:
```yaml
version: v1
directories:
  - beerapis
```

Finally, you have to run `buf generate` in the `grpc-beer-gateway/` directory to generate all the artifacts from the proto file.

## Enhance gRPC Service with Google HTTP API options

The gRPC service definition needs to be enhanced with service specific options to configure how the gRPC messages
are mapped to and from the HTTP body and path elements. Extend the `proto/beer.proto` in the `grpc-beer-gateway/` directory with the following content:

```proto
import "google/api/annotations.proto";

service BeerService {
    // Get the list of all beers
    rpc AllBeers (google.protobuf.Empty) returns (GetBeersResponse) {
        option (google.api.http) = {
            // map complete gRPC response to as HTTP response
            get: "/api/beers"
        };      
    }
    // Get a single beer by Asin
    rpc GetBeer (GetBeerRequest) returns (GetBeerResponse) {
        option (google.api.http) = {
            // map asin path param to asin field in request message
            // map beer field from response message to HTTP response body
            get: "/api/beers/{asin}"
            response_body: "beer"
        };
    }
    // Create a new beer
    rpc CreateBeer (CreateBeerRequest) returns (google.protobuf.Empty) {
        option (google.api.http) = {
            // map complete HTTP body to gRPC request message fields
            post: "/api/beers"
            body: "*"
        };
    }
    // Update an existing beer
    rpc UpdateBeer (UpdateBeerRequest) returns (google.protobuf.Empty) {
        option (google.api.http) = {
            // map asin path param to asin field in request message
            // map HTTP request body to beer field in request message
            put: "/api/beers/{asin}"
            body: "beer"
        };
    }
    // Delete an existing beeer
    rpc DeleteBeer (DeleteBeerRequest) returns (google.protobuf.Empty) {
        option (google.api.http) = {
            // map asin path param to asin field in request message
            delete: "/api/beers/{asin}"
        };
    }
}
```

After that you have to run `buf generate` in the `grpc-beer-gateway/` directory again.


Additionally, we can generate an OpenAPI v2 definition as well. Again, we need to enhance the proto file with
additional options. Extend the `proto/beer.proto` in the `grpc-beer-gateway/` directory with the following content:
```proto
import "protoc-gen-openapiv2/options/annotations.proto";

option (grpc.gateway.protoc_gen_openapiv2.options.openapiv2_swagger) = {
	info: {
		title: "gRPC Beer Gateway";
		version: "1.0";
		contact: {
			name: "Mario-Leander Reimer";
			url: "https://lreimer.github.io";
			email: "mario-leander.reimer@qaware.de";
		};
		license: {
			name: "MIT";
			url: "https://github.com/qaware/from-rest-to-grpc-workshop/blob/master/LICENSE";
		};		
	};
	external_docs: {
		url: "https://github.com/qaware/from-rest-to-grpc-workshop/grpc-beer-gateway";
		description: "Beer Service gRPC Gateway";
	}
	schemes: HTTP;
	schemes: HTTPS;
	consumes: "application/json";
	produces: "application/json";
};
```

After you have run `buf generate` in the `grpc-beer-gateway/` directory, you will find the generated OpenAPI V2 file in `gen/openapiv2/proto`. Just paste it at `https://editor.swagger.io/` to see if it works.

If your IDE complains that the newly added imports can't be resolved, you can fix this by copying the folders `google` and `protoc-gen-openapiv2` into the `proto` folder of the `grpc-beer-gateway/` directory.
For `Buf` this is not necessary as those dependencies are already listed in the `buf.yaml` file.

## Build and Deploy gRPC Gateway

```bash
# local development with Go (requires Go 1.17)
make build

# or containerized build
make image

# build and deploy microservice
# make sure to enable exercise-3 definitions in skaffold.yaml
skaffold dev --no-prune=false --cache-artifacts=false

# alternatively, use Tilt
# make sure to enable exercise-3 definitions in Tiltfile
tilt up

# use a HTTP client to call REST endpoints
http get localhost:18090/api/beers
curl -XGET http://localhost:18090/api/beers
```
