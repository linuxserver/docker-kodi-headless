FROM lsiobase/alpine:3.5
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Build-date:- ${BUILD_DATE}"

# package version
ARG KODI_NAME="Krypton"
ARG KODI_VER="17.1"

# copy patches
COPY patches/ /tmp/patches

# environment settings
ENV HOME="/config"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	afpfs-ng-dev \
	alsa-lib-dev \
	autoconf \
	automake \
	avahi-dev \
	bluez-dev \
	boost-dev \
	boost-thread \
	bsd-compat-headers \
	bzip2-dev \
	cmake \
	coreutils \
	curl-dev \
	dbus-dev \
	dcadec-dev \
	eudev-dev \
	faac-dev \
	ffmpeg-dev \
	file \
	findutils \
	flac-dev \
	freetype-dev \
	fribidi-dev \
	g++ \
	gawk \
	gcc \
	gettext-dev \
	giflib-dev \
	git \
	glew-dev \
	glu-dev \
	gnutls-dev \
	gperf \
	jasper-dev \
	lame-dev \
	lcms2-dev \
	libass-dev \
	libbluray-dev \
	libcap-dev \
	libcdio-dev \
	libcec-dev \
	libgcrypt-dev \
	libjpeg-turbo-dev \
	libmad-dev \
	libmicrohttpd-dev \
	libmodplug-dev \
	libmpeg2-dev \
	libnfs-dev \
	libogg-dev \
	libplist-dev \
	libpng-dev \
	libsamplerate-dev \
	libshairport-dev \
	libssh-dev \
	libtool \
	libva-dev \
	libvorbis-dev \
	libxmu-dev \
	libxrandr-dev \
	libxslt-dev \
	libxt-dev \
	lzo-dev \
	m4 \
	make \
	mariadb-dev \
	mesa-dev \
	nasm \
	openjdk8-jre-base \
	pcre-dev \
	python2-dev \
	rtmpdump-dev \
	samba-dev \
	sdl-dev \
	sdl_image-dev \
	sqlite-dev \
	swig \
	taglib-dev \
	tar \
	tiff-dev \
	tinyxml-dev \
	udisks2-dev \
	x264-dev \
	yajl-dev \
	yasm-dev \
	zip && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/main \
	libdvdcss-dev && \

# install runtime packages
 apk add --no-cache \
	alsa-lib \
	avahi-libs \
	bluez-libs \
	curl \
	eudev-libs \
	expat \
	ffmpeg-libs \
	freetype \
	fribidi \
	giflib \
	hicolor-icon-theme \
	lcms2 \
	libcap \
	libcdio \
	libdrm \
	libgcc \
	libmicrohttpd \
	libpcrecpp \
	libsmbclient \
	libssh \
	libstdc++ \
	libuuid \
	libva \
	libxext \
	libxml2 \
	libxrandr \
	libxslt \
	lzo \
	mariadb-client-libs \
	mesa-demos \
	mesa-egl \
	mesa-gl \
	musl \
	pcre \
	py-bluez \
	py-pillow \
	py-simplejson \
	python2 \
	sqlite-libs \
	taglib \
	tinyxml \
	unrar \
	xdpyinfo \
	yajl \
	zlib && \
 apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/main \
	libdvdcss && \

# fetch, unpack  and patch source
 mkdir -p \
	/tmp/kodi-source && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1 && \
 cd /tmp/kodi-source && \
 for i in /tmp/patches/"${KODI_NAME}"/* ; do git apply $i ; done && \

# configure source
 mkdir -p \
	/tmp/kodi-source/build && \
 cd /tmp/kodi-source/build && \
 cmake \
	../project/cmake/ \
		-DCMAKE_INSTALL_LIBDIR=/usr/lib \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DENABLE_AIRTUNES=OFF \
		-DENABLE_ALSA=OFF \
		-DENABLE_AVAHI=OFF \
		-DENABLE_BLUETOOTH=OFF \
		-DENABLE_BLURAY=ON \
		-DENABLE_CAP=OFF \
		-DENABLE_CEC=OFF \
		-DENABLE_DBUS=OFF \
		-DENABLE_DVDCSS=OFF \
		-DENABLE_LIBUSB=OFF \
		-DENABLE_NFS=ON \
		-DENABLE_NONFREE=OFF \
		-DENABLE_OPTICAL=OFF \
		-DENABLE_PULSEAUDIO=OFF \
		-DENABLE_SDL=OFF \
		-DENABLE_SSH=ON \
		-DENABLE_UDEV=OFF \
		-DENABLE_UPNP=ON \
		-DENABLE_VAAPI=OFF \
		-DENABLE_VDPAU=OFF && \

# compile and install kodi
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
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9777/udp
