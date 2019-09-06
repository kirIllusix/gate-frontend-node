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
    apt-get -fyqq install fonts-liberation libappindicator3-1 libatk-bridge2.0-0 libatspi2.0-0 libgtk-3-0 libxss1 xdg-utils libdbusmenu-glib4 libindicator3-7 libgtk-3-common libcairo-gobject2 libcolord1 libwayland-client0 libwayland-cursor0 libxkbcommon0 libdbusmenu-gtk3-4 dconf-gsettings-backend dconf-service libdconf1 && \
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

##############################################################################################################################

#Chrome browser to run the tests
ARG CHROME_VERSION=75.0.3770.80
RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add || true
RUN wget https://www.slimjet.com/chrome/download-chrome.php?file=files%2F$CHROME_VERSION%2Fgoogle-chrome-stable_current_amd64.deb \
		&& dpkg -i download-chrome*.deb

RUN apt-get install -y -f \
		&& rm -rf /var/lib/apt/lists/*

#Disable the SUID sandbox so that chrome can launch without being in a privileged container
#RUN dpkg-divert --add --rename --divert /opt/google/chrome/google-chrome.real /opt/google/chrome/google-chrome \
#        && echo "#! /bin/bash\nexec /opt/google/chrome/google-chrome.real --no-sandbox --disable-setuid-sandbox \"\$@\"" > /opt/google/chrome/google-chrome \
#        && chmod 755 /opt/google/chrome/google-chrome

#Chrome Driver
ARG CHROME_DRIVER_VERSION=2.46
RUN mkdir -p /opt/selenium \
        && curl http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -o /opt/selenium/chromedriver_linux64.zip \
        && cd /opt/selenium; unzip /opt/selenium/chromedriver_linux64.zip; rm -rf chromedriver_linux64.zip; ln -fs /opt/selenium/chromedriver /usr/local/bin/chromedriver;

##############################################################################################################################

#========================================
# Add normal user with passwordless sudo
#========================================
RUN set -xe \
    && useradd -u 1000 -g 100 -G sudo --shell /bin/bash --no-create-home --home-dir /tmp user \
    && echo 'ALL ALL = (ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

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
