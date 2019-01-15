FROM alpine:3.8
RUN apk update && apk add ca-certificates
COPY oauth2_proxy /usr/local/bin/oauth2_proxy
ENTRYPOINT ["oauth2_proxy"]
