![http://linuxserver.io](http://www.linuxserver.io/wp-content/uploads/2015/06/linuxserver_medium.png)

The [LinuxServer.io](http://linuxserver.io) team brings you another quality container release featuring auto-update on startup, easy user mapping and community support. Be sure to checkout our [forums](http://forum.linuxserver.io) or for real-time support our [IRC](http://www.linuxserver.io/index.php/irc/) on freenode at `#linuxserver.io`.

# linuxserver/kodi-headless

A headless install of kodi in a docker format, most useful for a mysql setup of kodi to allow library updates to be sent without the need for a player system to be permantely on. You can choose between (at the time of writing) 2 main versions of kodi. 14 helix and 15 isengard.

## Usage

```
docker create --name=<container-name> -v /etc/localtime:/etc/localtime:ro -v <path to data>:/config/.kodi -e PGID=<gid> -e PUID=<uid> -e VERSION=<version> -e TZ=<timezone> -p 8080:8080 -p 9777:9777 linuxserver/kodi-headless
```

**Parameters**

* `-p 8080` - webui port
* `-p 9777` - esall interface port
* `-v /etc/localtime` for timesync - *optional*
* `-v /config/.kodi` - path for kodi configuration files
* `-e TZ` - for timezone information *eg Europe/London, etc*
* `-e VERSION` - Main version of kodi *optional* - see below for explanation

It is based on phusion-baseimage with ssh removed, for shell access whilst the container is running do `docker exec -it kodi-headless /bin/bash`.

## Setting up the application
Set the optional VERSION variable to use an earlier release than what is current from kodi (use only the main version number, 14 , 15 etc, not point releases). Not setting or removing the VERSION variable will cause the container to update only releases within the same main version number you have installed.

Mysql/mariadb settings are entered by editing the file advancedsettings.xml which is found in the userdata folder of your /config/.kodi mapping. Many other settings are within this file also.

The default user/password for the web interface and for apps like couchpotato etc to send updates is xbmc/xbmc.  

If you intend to use this kodi instance to perform library tasks other than merely updating, eg. library cleaning etc, it is important to copy over the sources.xml from the host machine that you performed the initial library scan on to the userdata folder of this instance, otherwise database loss can and most likely will occur.

## Updates

* Upgrade to the latest version simply `docker restart kodi-headless`.
* To monitor the logs of the container in realtime `docker logs -f kodi-headless`.

## Credits
Various members of the xbmc/kodi community for patches and advice.

## Versions

+ **21.08.2015:** Initial Release.
