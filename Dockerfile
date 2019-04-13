FROM golang:1.12.1 AS build

WORKDIR /go/src/github.com/shuheiktgw/spinnaker-handson
COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server

FROM alpine:latest
COPY --from=build /go/src/github.com/shuheiktgw/spinnaker-handson/server /usr/local/bin/server
ENTRYPOINT ["/usr/local/bin/server"]