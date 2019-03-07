FROM lsiobase/ubuntu:bionic as buildstage
############## build stage ##############

# package versions
ARG KODI_NAME="Leia"
ARG KODI_VER="18.1"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# copy patches and excludes
COPY patches/ /patches/
COPY excludes /etc/dpkg/dpkg.cfg.d/excludes

RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y software-properties-common && \
 add-apt-repository -s ppa:team-xbmc/xbmc-nightly && \
 apt-get -y build-dep kodi
 
RUN \
 echo "**** fetch source and apply any patches if required ****" && \
 mkdir -p \
	/tmp/kodi-source/build && \
 echo "**** download ${KODI_VER}-${KODI_NAME}.tar.gz ****" && \
 curl -o \
 /tmp/kodi.tar.gz -L \
	"https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz" && \
 tar xf /tmp/kodi.tar.gz -C \
	/tmp/kodi-source --strip-components=1 && \
 cd /tmp/kodi-source && \
 patch -p1 \
	< /patches/"${KODI_NAME}"/headless.patch

RUN \
 echo "**** compile kodi ****" && \
 cd /tmp/kodi-source/build && \
 cmake ../. \
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
	-DENABLE_GLX=OFF \
	-DENABLE_LIBUSB=OFF \
	-DENABLE_NFS=ON \
	-DENABLE_NONFREE=OFF \
	-DENABLE_OPENGL=OFF \
	-DENABLE_OPTICAL=OFF \
	-DENABLE_PULSEAUDIO=OFF \
	-DENABLE_SDL=OFF \
	-DENABLE_SNDIO=OFF \
	-DENABLE_SSH=ON \
	-DENABLE_UDEV=OFF \
	-DENABLE_UPNP=ON \
	-DENABLE_VAAPI=OFF \
	-DENABLE_VDPAU=OFF && \
 make && \
 make DESTDIR=/tmp/kodi-build install

RUN \
 echo "**** install kodi-send ****" && \
 install -Dm755 \
	/tmp/kodi-source/tools/EventClients/Clients/KodiSend/kodi-send.py \
	/usr/bin/kodi-send && \
 install -Dm644 \
	/tmp/kodi-source/tools/EventClients/lib/python/xbmcclient.py \
	/usr/lib/python2.7/xbmcclient.py

############### runtime ###################
FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sinopsyHK"

# package versions
# set KODI_REPO to "ppa" for stable repo and "unstable" for unstable.
ARG KODI_REPO="ppa"

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
 apt-get install -y \
	--no-install-recommends \
	libass9 \
	libbluray2 \
	libcurl4 \
	libegl1-mesa \
	libfreetype6 \
	libfribidi0 \
	libfstrcmp0 \
	libglew2.0 \
	liblcms2-2 \
	liblirc-dev \
	liblzo2-2 \
	libmicrohttpd12 \
	libmysqlclient20 \
	libnfs11 \
	libpcrecpp0v5 \
	libpython2.7 \
	libsmbclient \
	libsndio6.1 \
	libssh-4 \
	libtag1v5 \
	libtinyxml2.6.2v5 \
	libva-drm2 \
	libva-x11-2 \
	libvdpau1 \
	libxml2 \
	libxrandr2 \
	libxslt1.1 \
	libyajl2 \
	python && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \ 
	/var/tmp/*

# copy local files
COPY root/ /
# copy local files and buildstage artifacts
COPY --from=buildstage /tmp/kodi-build/usr/ /usr/
COPY --from=buildstage /usr/bin/kodi-send /usr/bin/kodi-send
COPY --from=buildstage /usr/lib/python2.7/xbmcclient.py /usr/lib/python2.7/xbmcclient.py

# ports and volumes
VOLUME /config/.kodi
EXPOSE 8080 9090 9777/udp
