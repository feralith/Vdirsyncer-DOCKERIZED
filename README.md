# [Vdirsyncer](https://vdirsyncer.pimutils.org/en/stable/index.html "Official Documentation")-DOCKERIZED

Vdirsyncer - sync calendars and addressbooks between servers and the local filesystem. DOCKERIZED! 

## About Vdirsyncer

**Disclaimer:** I am just the maintainer of this docker container, i did not write the software. Visit the [Official Github Repository](https://github.com/pimutils/vdirsyncer "Vdirsyncer Github Repository") to thank the author(s)! :)

**Note:** Version 2.0 is an almost complete rewrite, if you have used 1.0.1 or 1.0 you have to adjust some things!

Vdirsyncer is a command-line tool for synchronizing calendars and addressbooks between a variety of servers and the local filesystem. The most popular usecase is to synchronize a server with a local folder and use a set of other programs to change the local events and contacts. Vdirsyncer can then synchronize those changes back to the server.

However, vdirsyncer is not limited to synchronizing between clients and servers. It can also be used to synchronize calendars and/or addressbooks between two servers directly.

It aims to be for calendars and contacts what [OfflineIMAP](https://github.com/OfflineIMAP/offlineimap "OfflineIMAP Github Repository") is for emails.

Vdirsyncer also support many different servers:
* Baikal
* DavMail (Exchange, Outlook)
* FastMail
* Google
* iCloud
* Mailcow (SOGo)
* NextCloud
* Radicale
* Xandikos

Official Github Repository - https://github.com/pimutils/vdirsyncer

Docs - https://vdirsyncer.pimutils.org/en/stable/tutorial.html

My Github Repository - https://github.com/Bleala/Vdirsyncer-DOCKERIZED

Docker Hub - https://hub.docker.com/r/bleala/vdirsyncer

---
## Image, Versions and Architecture

I built this image based on [Alpine Linux](https://hub.docker.com/_/alpine "Alpine Linux Image") and set up everything with python3 and pip3.

There will always be two different versions:

| Tag | Content |
| ------------- |:-------------:|
| Latest    | Contains the latest stable version |
| 2.x     | Contains the Vdirsyncer, Python and Alpine versions mentioned at the bottom of the page | 

There are also several platforms supported:

Platform:
* linux/amd64
* linux/arm64 
* linux/arm/v7

---

## Usage

To start the container you can run `docker run -d -e AUTOSYNC=true -v /path/to/local/folder:/vdirsyncer bleala/vdirsyncer:latest`, but since docker-compose is easier to maintain, i'll give you a valid docker-compose example


```docker-compose.yml
version: "3.9"

networks:                                 
  default:
    driver: bridge

services:
  # Vdirsyncer - sync calendars and addressbooks between servers and the local filesystem. DOCKERIZED!
  # https://hub.docker.com/r/bleala/vdirsyncer
  app:
    image: bleala/vdirsyncer:latest
    container_name: vdirsyncer
    restart: unless-stopped
    networks:
      - default
    environment:
      - AUTODISCOVER= # set to true for automatic discover, default to false
      - AUTOSYNC= # set to true for automatic sync, default to false
      - LOG= # optional, default to /vdirsyncer/log/vdirsyncer.log
      - CRON_TIME= # adjust autosync /-discover time, default to 15 minutes - */15 * * * * 
      # Cron Time need to be set in Cron format - look here for generator https://crontab.guru/
      # Set CRON_TIME like that --> */15 * * * *
    volumes:
      - /path/to/folder:/vdirsyncer
      - /etc/localtime:/etc/localtime:ro # Pass Host time to container, important to get the correct log timestamp

```

You have to mount a local folder containing the *config* file. [How to config](http://vdirsyncer.pimutils.org/en/stable/tutorial.html "Vdirsyncer configuration")

In the mounted folder you will also find a *config.example* which i copied inside the container for a quick reference.

The configuration file name is just **config**. Write everything in *.ini* style, like it is shown in the docs and in my *config.example*!

**Attention:** It is not recommended to use `AUTODISCOVER=true` by default, if you have never used *Vdirsyncer* before! If you set it to true, it will automatically accept everything `Vdirsyncer` asks, so don't ruin your calender/contacts structure! **Use it only if you know what you are doing!**

For first time use i recommend running `docker exec -it vdirsyncer vdirsyncer discover`. Maybe you have to say yes/no to a few questions, asked by *Vdirsyncer*. **[READ THE DOCS!](http://vdirsyncer.pimutils.org/en/stable/tutorial.html "Official Documentation")**

After you ran `docker exec -it vdirsyncer vdirsyncer discover` you can either run `docker exec -it vdirsyncer vdirsyncer metasync && vdirsyncer sync` or, if you have not set `AUTOSYNC=true`, set it to *true* and restart the container with `docker-compose restart`. If you already set it to true, you can just wait until the cronjob runs or, as i said, run `docker exec -it vdirsyncer vdirsyncer metasync && vdirsyncer sync` to do it manually once.

Now it will sync everything for the first time.

When everything is okay, you can adjust the `CRON_TIME` value to your desired time. Check out [Crontab.guru](https://crontab.guru/ "Crontab.guru") for help. Default synctime value is 15 minutes `CRON_TIME=*/15 * * * *`.

Everything that is done by *Cron* will get written to the *log file* and to the docker logs! Run `docker logs -f vdirsyncer` or `docker-compose logs -f` to watch the logs.

**Attention for Google users:** As you can read in the [Docs](http://vdirsyncer.pimutils.org/en/stable/config.html#google "Google Docs Vdirsyncer") you have to specify a path for `token_file = "PATH"`. In order to work properly, use an **absolute path!** So for the carddav storage set the `token_file` like `token_file = "/vdirsyncer/google_carddav"`and for the caldav storage like `token_file = "/vdirsyncer/google_calendar"`. The reason is, cron does not run the `vdirsyncer` command directly inside the `/vdirsyncer` folder, so if you use a relative path, `vdirsyncer` does not know where your google tokens are stored and the `AUTOSYNC` fails!


### Environment Variables

You can set five different environment variables if you want to:

* `AUTODISCOVER` - default to false, is used to automatically run `vdirsyncer discover`.
* `AUTOSYNC` - default to false, is used to automatically run `vdirsyncer metasync && vdirsyncer sync`
* `CRON_TIME` - default to `*/15 * * * *` (15 minutes), you can adjust it to whatever time you want to.
* `LOG` - optional, default to `/vdirsyncer/logs/vdirsyncer.log`, if you want to adjust the log file destination.
* `VDIRSYNCER_CONFIG` - location, where *Vdirsyncer* reads the config from, default to /vdirsyncer/config **DON'T CHANGE!** 

---

**Attention**: As i mentioned, don't use `AUTODISCOVER=true` as default. If you are running *Vdirsyncer* for the first time, just try everything manually, before you enable `AUTOSYNC` and `AUTODISCOVER`!

**Attention 2**: I recommend using this way for the pairs `collections = [["mytest", "test", "3b4c9995-5c67-4021-9fa0-be4633623e1c"]]` [LINK](http://vdirsyncer.pimutils.org/en/stable/tutorial.html#advanced-collection-configuration-server-to-server-sync)

**Attention 3**: Nextcloud fucks up the whole thing pretty much, if you try to sync contacts from Nextcloud to Google or Apple. I don't know why, maybe it's a bug in *vdirsyncer*, so i decided to pair Nextcloud with a [read_only](http://vdirsyncer.pimutils.org/en/stable/tutorial.html#advanced-collection-configuration-server-to-server-sync) storage. This way Nextcloud gets everything and does not fuck things up (Maybe also a problem with Owncloud, but i did not test it) 

---

## Versions

**2.1.1 - 29.08.2021:** Added Log Timestamp and bumped Alpine to 3.14.2 - Vdirsyncer 0.18.0, Alpine 3.14.2, Python 3.9.5, Pip 20.3.4

**2.1 - 27.08.2021:** Added Log Persistence and Docker Image at [Github Container Registry](https://github.com/Bleala/Vdirsyncer-DOCKERIZED/pkgs/container/vdirsyncer "Github Container Registry") available - Vdirsyncer 0.18.0, Alpine 3.14.1, Python 3.9.5, Pip 20.3.4

**2.0 - 22.08.2021:** Almost a complete Rewrite, dropped Ofelia and implemented Cron - Vdirsyncer 0.18.0, Alpine 3.14.1, Python 3.9.5, Pip 20.3.4

**1.0.1 - 20.08.2021:** Adjusted config.example - Vdirsyncer 0.18.0, Alpine 3.14.1, Python 3.9.5, Pip 20.3.4

**1.0 - 20.08.2021:** Inital Docker Hub Push - Vdirsyncer 0.18.0, Alpine 3.14.1, Python 3.9.5, Pip 20.3.4


---
### Hope you enjoy it! :)
---
