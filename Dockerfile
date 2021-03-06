FROM golang:1.9.1

WORKDIR /go/src/github.com/reportportal/service-analyzer/
ARG version

## Copy makefile and glide before to be able to cache vendor
COPY Makefile ./
RUN make get-build-deps

COPY glide.yaml ./
COPY glide.lock ./

RUN make vendor

ENV VERSION=$version

RUN make get-build-deps
COPY ./ ./
RUN make build

FROM alpine:latest
ARG service
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/reportportal/service-analyzer/bin/service-analyzer ./app
CMD ["./app"]
