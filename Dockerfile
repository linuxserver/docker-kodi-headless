FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# package versions
# set KODI_REPO to "ppa" for stable repo and "unstable" for unstable.
ARG KODI_REPO="unstable"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

RUN \
 echo "**** install gnupg ****" && \
 apt-get update && \
 apt-get install -y \
	gnupg && \
 echo "add kodi repository ****" && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 91E7EE5E && \
 echo "deb http://ppa.launchpad.net/team-xbmc/${KODI_REPO}/ubuntu bionic main" >> \
	/etc/apt/sources.list.d/kodi.list && \
 echo "deb-src http://ppa.launchpad.net/team-xbmc/${KODI_REPO}/ubuntu bionic main" >> \
	/etc/apt/sources.list.d/kodi.list && \
 apt-get update && \
 apt-get install --no-install-recommends -y \
	kodi \
	pulseaudio \
	xpra && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \ 
	/var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9090 9777/udp
