# gRPC Web Client and Proxy

gRPC Web is a JavaScript implementation of gRPC for browser clients. gRPC-web clients connect to gRPC services via a special proxy; by default, gRPC-web uses Envoy. For more information, including a quick start, see the gRPC-web documentation https://grpc.io/docs/platforms/web/ and https://github.com/grpc/grpc-web

For that exercise you have to install the `protoc-gen-grpc-web` plugin first. See: https://github.com/grpc/grpc-web#code-generator-plugin

## Configure the Envoy Proxy

We will use the Envoy proxy to forward the gRPC browser request to the backend server. You can see the complete config file in envoy.yaml, add it to the `grpc-beer-envoy/` folder.
```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 8091 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route:
                  cluster: beer_service
                  max_stream_duration:
                    grpc_timeout_header_max: 0s
              cors:
                allow_origin_string_match:
                - prefix: "*"
                allow_methods: GET, PUT, DELETE, POST, OPTIONS
                allow_headers: keep-alive,user-agent,cache-control,content-type,content-transfer-encoding,x-accept-content-transfer-encoding,x-accept-response-streaming,x-user-agent,x-grpc-web,grpc-timeout
                max_age: "1728000"
                expose_headers: grpc-status,grpc-message
          http_filters:
          - name: envoy.filters.http.grpc_web
          - name: envoy.filters.http.cors
          - name: envoy.filters.http.router
  clusters:
  - name: beer_service
    connect_timeout: 0.25s
    type: logical_dns
    http2_protocol_options: {}
    lb_policy: round_robin
    load_assignment:
      cluster_name: cluster_0
      endpoints:
        - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: grpc-beer-service
                    port_value: 9090
```

## Generate Protobuf Messages and Service Client Stub

The process of generating the required JavaScript and TS sources from the Proto files is a bit tedious when done by hand or calling the protoc compiler on the command line. The tool Buf greatly simplifies the process.

First we need to configure Buf with the correct dependencies and proto source roots. Create a file `buf.yaml` in the `grpc-beer-javascript/` directory with the following content.
```yaml
version: v1
deps:
  - buf.build/googleapis/googleapis
```

Next we need to configure the JS and grpc-web protoc plugins used to generate the required JavaScript and TS source files. Create a file `buf.gen.yaml` in the `grpc-beer-javascript/` directory with the following content.
```yaml
version: v1
plugins:
  # this required grpc-web plugin installed
  - name: js
    out: .
    opt: import_style=commonjs
  - name: grpc-web
    out: .
    opt: import_style=commonjs+dts,mode=grpcwebtext
```

Also create a file `buf.work.yaml` with the following content:
```yaml
version: v1
directories:
  - proto
```


Finally, you have to run `buf generate` to generate all the artifacts from the proto file.

On MacOS you may get the following error because of an open issue: https://github.com/protocolbuffers/protobuf-javascript/issues/127
```
protoc-gen-js: program not found or is not executable
Please specify a program using absolute path or make sure the program is available in your PATH system variable
--js_out: protoc-gen-js: Plugin failed with status code 1.
Failure: plugin js: exit status 1
```
This issue seems to affect `protoc` versions `> 3.20.1`.
As a workaround you can downgrade to `protoc` version `3.20.1`. See: https://github.com/protocolbuffers/protobuf-javascript/issues/127#issuecomment-1204202844

## Implement Client in JavaScript

With the generated files for the messages and client stubs, we can now implement the client application
in JavaScript. Create a file called `beer_client.js` in the `grpc-beer-javascript/` project folder with
the following content.
```javascript
const {Empty} = require('./node_modules/google-protobuf/google/protobuf/empty_pb.js')
const {GetBeerRequest, GetBeerResponse} = require('./beer_pb.js')
const {BeerServiceClient} = require('./beer_grpc_web_pb.js')

var beerClient = new BeerServiceClient('http://localhost:18091');

var empty = new Empty();
beerClient.allBeers(empty, {}, function(err, response){
    if (err) {
        console.log(err.code);
        console.log(err.message);
    } else {
        console.log(response.getBeersList());
    }
});

var request = new GetBeerRequest();
request.setAsin('B079V9ZDNY')

beerClient.getBeer(request, {}, function(err, response){
    if (err) {
        console.log(err.code);
        console.log(err.message);
    } else {
        console.log(response.getBeer());
    }
});
```

## Build and Deploy gRPC Web Proxy and Client

```bash
# build and deploy proxy
# make sure to enable exercise-4 definitions in skaffold.yaml
skaffold dev --no-prune=false --cache-artifacts=false

# alternatively, use Tilt
# make sure to enable exercise-3 definitions in Tiltfile
tilt up

# build and package the app
npm install
npx webpack ./beer_client.js

# open the index.html in browser. Open the developer tools and check the output on the developer console
open index.html
```
