# DEPRECATION NOTICE

This image is deprecated. We will not offer support for this image and it will not be updated.
This project is no longer maintained.

[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/index.php/irc/
[podcasturl]: https://www.linuxserver.io/index.php/category/podcast/
[appurl]: https://kodi.tv/
[hub]: https://hub.docker.com/r/linuxserver/kodi-headless/

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

The [LinuxServer.io][linuxserverurl] team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/kodi-headless
[![](https://images.microbadger.com/badges/version/linuxserver/kodi-headless.svg)](https://microbadger.com/images/linuxserver/kodi-headless "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/image/linuxserver/kodi-headless.svg)](https://microbadger.com/images/linuxserver/kodi-headless "Get your own image badge on microbadger.com")[![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/kodi-headless.svg)][hub][![Docker Stars](https://img.shields.io/docker/stars/linuxserver/kodi-headless.svg)][hub][![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Builders/x86-64/x86-64-kodi-headless)](https://ci.linuxserver.io/job/Docker-Builders/job/x86-64/job/x86-64-kodi-headless/)

A headless install of kodi in a docker container, most useful for a mysql setup of kodi to allow library updates to be sent without the need for a player system to be permanently on.

[![kodi](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/kodi-banner.png)][appurl]

## Usage

```
docker create --name=kodi-headless \
-v <path to data>:/config/.kodi \
-e PGID=<gid> -e PUID=<uid> \
-e TZ=<timezone> \
-p 8080:8080 \
-p 9090:9090 \
-p 9777:9777/udp \
linuxserver/kodi-headless
```

You can choose between ,using tags, various main versions of kodi.

Add one of the tags,  if required,  to the linuxserver/kodi-headless line of the run/create command in the following format, linuxserver/kodi-headless:Krypton

#### Tags
+ **Helix**
+ **Isengard**
+ **Jarvis**
+ **Krypton**
+ **Leia** : current default branch.


**Parameters**

* `-p 8080` - webui port
* `-p 9090` - websockets port
* `-p 9777/udp` - esall interface port
* `-v /config/.kodi` - path for kodi configuration files
* `-e PGID` for GroupID - see below for explanation
* `-e PUID` for UserID - see below for explanation
* `-e TZ` - for timezone information *eg Europe/London, etc*

It is based on ubuntu bionic with s6 overlay, for shell access whilst the container is running do `docker exec -it kodi-headless /bin/bash`.

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

Mysql/mariadb settings are entered by editing the file advancedsettings.xml which is found in the userdata folder of your /config/.kodi mapping. Many other settings are within this file also.

The default user/password for the web interface and for apps like couchpotato etc to send updates is kodi/kodi.

If you intend to use this kodi instance to perform library tasks other than merely updating, eg. library cleaning etc, it is important to copy over the sources.xml from the host machine that you performed the initial library scan on to the userdata folder of this instance, otherwise database loss can and most likely will occur.

Rar integration with the Leia branch is now handled by an addon,
it is compiled with this build, but you will need to enable it, if required, in the settings section of the webui.

## Info

* Shell access whilst the container is running: `docker exec -it kodi-headless /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f kodi-headless`

## Credits
For inspiration, and most importantly, the headless patches without which none of this would have been possible. 

+ [Celedhrim](https://github.com/Celedhrim)
+ [sinopsysHK](https://github.com/sinopsysHK)
+ [wernerb](https://github.com/wernerb)

Various other members of the xbmc/kodi community for advice.

## Versions

+ **07.01.20:** Bump Leia to 18.5.
+ **23.06.19:** Bump Leia to 18.4.
+ **23.04.19:** Bump Leia to 18.2.
+ **09.03.19:** Build vfs.libarchive and vfs.rar addons.
+ **08.03.19:** Make Leia default branch, using patched "headless" build.
+ **30.01.19:** Bump Leia branch to release ppa.
+ **03.09.18:** Add back libnfs dependency.
+ **31.08.18:** Rebase to ubuntu bionic, use buildstage and add info about websockets port.
+ **04.01.18:** Deprecate cpu_core routine lack of scaling.
+ **14.12.17:** Fix continuation lines.
+ **17.11.17:** Bump Krypton to 17.6.
+ **24.10.17:** Bump Krypton to 17.5.
+ **22.08.17:** Bump Krypton to 17.4.
+ **25.05.17:** Bump Krypton to 17.3.
+ **23.05.17:** Bump Krypton to 17.2.
+ **23.04.17:** Refine cmake, use cmake ppa and take out uneeded bootstrap line.
+ **22.02.17:** Switch to using cmake build system.
+ **22.02.17:** Bump Krypton to 17.1.
+ **22.02.17:** Change default webui user/pw to kodi/kodi.
+ **05.02.17:** Move Krypton to default branch.
+ **20.09.16:** Add kodi-send and fix var cache samba permissions.
+ **10.09.16:** Add layer badge to README..
+ **02.09.16:** Rebase to alpine linux.
+ **13.03.16:** Make kodi 16 (jarvis) default installed version.
+ **21.08.15:** Initial Release.
