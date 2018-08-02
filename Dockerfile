FROM golang:1.10.3-alpine3.8
RUN apk add --no-cache --update alpine-sdk
RUN go get -u github.com/golang/dep/cmd/dep
COPY . /go/src/github.com/bitly/oauth2_proxy
RUN cd /go/src/github.com/bitly/oauth2_proxy && make release && cp build/oauth2_proxy /go/bin

FROM alpine:3.8
COPY --from=0 /go/bin/oauth2_proxy /usr/local/bin/oauth2_proxy
ENTRYPOINT ["oauth2_proxy"]
