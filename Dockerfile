# FROM node:8.12.0-alpine

# USER root
# RUN mkdir /root/.npm-global
# ENV PATH=/root/.npm-global/bin:$PATH
# ENV NPM_CONFIG_PREFIX=/root/.npm-global

#FROM node:6.9.1-slim
#FROM node:6.9.1-stretch
#FROM node:6.9.1-jessie

#FROM node:6.9.1-alpine
# RUN apk add --no-cache \
#     bash \
#     make \
#     python


# RUN npm_config_user=root npm install -g node-gyp \
#  && npm cache clear --force

# RUN node-gyp configure || echo ""

FROM ubuntu:trusty
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ccache \
		cmake \
		equivs \
		fakeroot \
		gcc \
		make \
		sudo \
		wget \
          curl \
          git \
	&& rm -rf /var/lib/apt/lists/*

#ENV NODE_VERSION='10.10.0'
ENV NODE_VERSION='8.12.0'
RUN set -xe && \
    wget https://nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz --no-check-certificate && \
    tar -xJvf node-v${NODE_VERSION}-linux-x64.tar.xz && \
    mkdir -p /usr/local/lib/node && \
    mv node-v${NODE_VERSION}-linux-x64 /usr/local/lib/node/nodejs && \
    ln -s /usr/bin/nodejs /usr/bin/node

ENV NODEJS_HOME="/usr/local/lib/node/nodejs/bin"
ENV PATH="${NODEJS_HOME}:${PATH}"

RUN npm_config_user=root npm install -g \
     grunt-cli@1.2.0 \
     bower@1.8.0 \
     coffee-script@1.12.0 \
     webpack@2.2.1 \
     eslint@2.13.1 \
     && npm cache clean --force

#RUN mkdir -p /var/www && chown node:node  /var/www && chmod 777 /var/www
RUN mkdir -p /var/www && chmod -R 777 /var/www

VOLUME /var/www
WORKDIR /var/www