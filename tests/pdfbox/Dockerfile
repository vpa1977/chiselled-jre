ARG MAVEN_IMAGE
ARG USER=app
ARG UID=101
ARG GROUP=app
ARG GID=101

FROM golang:1.20 AS chisel
RUN git clone  --depth 1 -b debian-bookworm https://github.com/vpa1977/chisel-releases /opt/chisel-releases \
    && git clone --depth 1 -b debian-support https://github.com/vpa1977/chisel /opt/chisel
WORKDIR /opt/chisel
RUN go generate internal/deb/version.go \
    && go build ./cmd/chisel

FROM debian:bookworm AS builder
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates \
        ca-certificates-java \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=chisel /opt/chisel/chisel /usr/bin/

### BOILERPLATE END ###

FROM builder AS sliced-deps
ARG USER
ARG UID
ARG GROUP
ARG GID
SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]
COPY --from=chisel /opt/chisel-releases /opt/chisel-releases
RUN mkdir -p /rootfs \
      && chisel cut --release /opt/chisel-releases --root /rootfs \
        liblcms2-2_libs \
        libfontconfig1_libs \
        libfreetype6_libs \
        libjpeg-turbo8_libs

FROM $MAVEN_IMAGE
COPY --from=sliced-deps /rootfs /
