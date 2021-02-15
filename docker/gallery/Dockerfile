FROM alpine:3.10.5

MAINTAINER andre@clarin.eu

ARG BUILD_BASE_VERSION=0.5-r1
ARG NPM_VERSION=10.19.0-r0
ARG PYTHON_VERSION=2.7.18-r0

RUN apk add --no-cache \
	npm=$NPM_VERSION \
	build-base=$BUILD_BASE_VERSION \
	python=$PYTHON_VERSION \
	exiftool=11.45-r0 \
	graphicsmagick=1.3.33-r0

RUN npm i npm@7.5.4 -g \
    && npm i thumbsup -g


