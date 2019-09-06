FROM ubuntu:trusty

#
# BASE PACKAGES
#
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
		unzip \
		jq \
		zip \
		xvfb \
		default-jre \
		build-essential && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Update the repositories
RUN apt-get -yqq update && \
    apt-get -yqq install xvfb tinywm && \
    apt-get -yqq install fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic && \
    apt-get -yqq install python && \
    rm -rf /var/lib/apt/lists/*

# Install NodeJs
ENV NODE_VERSION='8.12.0'
RUN set -xe && \
    wget https://nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz --no-check-certificate && \
    tar -xJvf node-v${NODE_VERSION}-linux-x64.tar.xz && \
    mkdir -p /usr/local/lib/node && \
    mv node-v${NODE_VERSION}-linux-x64 /usr/local/lib/node/nodejs && \
    ln -s /usr/bin/nodejs /usr/bin/node

ENV NODEJS_HOME="/usr/local/lib/node/nodejs/bin"
ENV PATH="${NODEJS_HOME}:${PATH}"

# Install NodeJs global modules
RUN npm_config_user=root npm install -g \
     grunt-cli@1.2.0 \
     bower@1.8.0 \
     coffee-script@1.12.0 \
     webpack@2.2.1 \
     eslint@2.13.1 \
     && npm cache clean --force

RUN mkdir -p /var/www && chmod -R 777 /var/www

VOLUME /var/www
WORKDIR /var/www

# Install Chrome WebDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION && \
    rm /tmp/chromedriver_linux64.zip && \
    chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver && \
    ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get -yqq update && \
    apt-get -yqq install google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Default configuration
ENV DISPLAY :20.0
ENV SCREEN_GEOMETRY "1440x900x24"
ENV CHROMEDRIVER_PORT 4444
ENV CHROMEDRIVER_WHITELISTED_IPS "127.0.0.1"
ENV CHROMEDRIVER_URL_BASE ''
ENV CHROMEDRIVER_EXTRA_ARGS ''

#
# INSTALL AND CONFIGURE
#
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
RUN chmod u+rx,g+rx,o+rx,a-w /opt/docker-entrypoint.sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]