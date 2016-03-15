FROM alpine

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go

RUN	apk --no-cache --update add \
	ca-certificates \
	openssl \
	&& rm -rf /var/cache/apk/*

EXPOSE 8080

COPY . /go/src/github.com/cloudflare/redoctober
COPY script/generatecert /usr/local/bin/
COPY script/docker-start /usr/local/bin/

WORKDIR /

RUN buildDeps=' \
		go \
		git \
		gcc \
		libc-dev \
		libgcc \
	' \
	set -x \
	&& apk add --update --no-cache $buildDeps \
	&& cd /go/src/github.com/cloudflare/redoctober \
	&& go get -d -v github.com/cloudflare/redoctober \
	&& go build -o /usr/bin/redoctober . \
	&& mkdir -p /data \
	&& apk del $buildDeps \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /go \
	&& echo "Build complete."


ENTRYPOINT ["/usr/local/bin/docker-start"]
CMD ["-addr=:8080", "-vaultpath=/data/diskrecord.json", "-certs=/cert/server.crt", "-keys=/cert/server.pem"]
