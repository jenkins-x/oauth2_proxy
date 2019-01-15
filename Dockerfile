FROM alpine:3.8
RUN apk update && apk add ca-certificates
COPY oauth2_proxy /usr/local/bin/oauth2_proxy
# symlink the libraries required to run on alpine
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
ENTRYPOINT ["oauth2_proxy"]
