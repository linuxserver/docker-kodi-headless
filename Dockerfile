FROM lsiobase/xenial
MAINTAINER sparklyballs

# package version
ARG KODI_NAME="Krypton"
ARG KODI_VER="17.0rc3"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Build-date:- ${BUILD_DATE}"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# copy patches and excludes
COPY patches/ /patches/

# install build packages
RUN \
 echo "deb http://ppa.launchpad.net/team-xbmc/xbmc-nightly/ubuntu xenial main " >> \
	/etc/apt/sources.list.d/kodi.list && \
 echo "deb-src http://ppa.launchpad.net/team-xbmc/xbmc-nightly/ubuntu xenial main" >> \
	/etc/apt/sources.list.d/kodi.list && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 91E7EE5E && \
 apt-get update && \
 apt-get install -y \
	git && \
 apt-get \
	build-dep kodi -y && \

# fetch, unpack  and patch source
 mkdir -p \
	/tmp/kodi-source && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1 && \
 cd /tmp/kodi-source && \
 git apply \
	/patches/"${KODI_NAME}"/headless.patch && \

# configure source
 ./bootstrap && \
	./configure \
		--build=$CBUILD \
		--disable-airplay \
		--disable-airtunes \
		--disable-alsa \
		--disable-asap-codec \
		--disable-avahi \
		--disable-dbus \
		--disable-debug \
		--disable-dvdcss \
		--disable-goom \
		--disable-joystick \
		--disable-libcap \
		--disable-libcec \
		--disable-libusb \
		--disable-non-free \
		--disable-openmax \
		--disable-optical-drive \
		--disable-projectm \
		--disable-pulse \
		--disable-rsxs \
		--disable-rtmp \
		--disable-spectrum \
		--disable-udev \
		--disable-vaapi \
		--disable-vdpau \
		--disable-vtbdecoder \
		--disable-waveform \
		--enable-libbluray \
		--enable-nfs \
		--enable-ssh \
		--enable-static=no \
		--enable-upnp \
		--host=$CHOST \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--prefix=/usr \
		--sysconfdir=/etc && \

# compile and install kodi
 make && \
 make install && \

# install kodi-send
 install -Dm755 \
	/tmp/kodi-source/tools/EventClients/Clients/Kodi\ Send/kodi-send.py \
	/usr/bin/kodi-send && \
 install -Dm644 \
	/tmp/kodi-source/tools/EventClients/lib/python/xbmcclient.py \
	/usr/lib/python2.7/xbmcclient.py && \

# cleanup
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9777/udp
