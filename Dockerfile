FROM lsiobase/xenial
MAINTAINER sparklyballs

# package version
ARG KODI_NAME="Helix"
ARG KODI_VER="14.2"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Build-date:- ${BUILD_DATE}"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# copy patches and excludes
COPY patches/ /patches/
COPY excludes /etc/dpkg/dpkg.cfg.d/excludes

# build pack variable
ARG BUILD_LIST="\
	ant \
	autoconf \
	automake \
	autopoint \
	binutils \
	cmake \
	curl \
	default-jdk \
	doxygen \
	g++ \
	gawk \
	gcc \
	git-core \
	gperf \
	libass-dev \
	libavahi-client-dev \
	libbluray-dev \
	libboost1.58-dev \
	libbz2-ocaml-dev \
	libcap-dev \
	libcurl4-openssl-dev \
	libflac-dev \
	libfreetype6-dev \
	libgif-dev \
	libgle3-dev \
	libglew-dev \
	libgnutls-dev \
	libiso9660-dev \
	libjasper-dev \
	libjpeg-dev \
	liblzo2-dev \
	libmicrohttpd-dev \
	libmodplug-dev \
	libmpeg2-4-dev \
	libmysqlclient-dev \
	libnfs-dev \
	libpcre3-dev \
	libsdl-dev \
	libsdl-ocaml-dev \
	libsmbclient-dev \
	libsqlite3-dev \
	libssh-dev \
	libtag1-dev \
	libtiff5-dev \
	libtinyxml-dev \
	libtool \
	libvorbis-dev \
	libxml2-dev \
	libxrandr-dev \
	libxslt-dev \
	libyajl-dev \
	m4 \
	make \
	openjdk-8-jre-headless \
	python-dev \
	swig \
	uuid-dev \
	yasm \
	zip"

# install build packages
RUN \
 apt-get update && \
 apt-get install -y \
 	$BUILD_LIST && \

# fetch, unpack  and patch source
 mkdir -p \
	/tmp/kodi-src && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-src --strip-components=1 && \
 cd /tmp/kodi-src && \
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
	/tmp/kodi-src/tools/EventClients/Clients/Kodi\ Send/kodi-send.py \
	/usr/bin/kodi-send && \
 install -Dm644 \
	/tmp/kodi-src/tools/EventClients/lib/python/xbmcclient.py \
 /usr/lib/python2.7/xbmcclient.py && \

# cleanup
 apt-get purge --remove -y \
	$BUILD_LIST && \
 apt-get autoremove -y && \
 apt-get autoclean -y && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# install runtime packages
RUN \
 apt-get update && \
 apt-get install -y \
 --no-install-recommends \
	libcurl3 \
	libfreetype6 \
	libfribidi0 \
	libglew1.13 \
	libglu1-mesa \
	libjpeg8 \
	liblzo2-2 \
	libmicrohttpd10 \
	libmodplug1 \
	libmysqlclient20 \
	libnfs8 \
	libpcrecpp0v5 \
	libpython2.7 \
	libsdl1.2debian \
	libsmbclient \
	libssh-4 \
	libtag1v5 \
	libtinyxml2.6.2v5 \
	libvorbisenc2 \
	libxml2 \
	libxrandr2 \
	libxslt1.1 \
	libyajl2 && \
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
