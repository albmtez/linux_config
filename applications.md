# Applications

[TOC]

---

## Transmission

We only have to install the following packages:

```sh
sudo apt-get install transmission-cli transmission-common transmission-daemon
```

We can check the status of the service:

```sh
sudo service transmission-daemon status
```

We have to configure the password to access the web interface and the allowed IPs editting the file `/etc/transmission-daemon/settings.json`. Add to `rpc-whitelist` the allowed IPs:

```sh
"rpc-whitelist": "127.0.0.1, 192.168.1.*"
```

Reload the configuration and we are done:

```sh
sudo service transmission-daemon reload
```

Transmission is available at: `http://server_ip:9091`.

## Plex Media Server

### Install

Import the GPG key and add the repository:

```sh
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
```

Update and install Plex:

```sh
sudo apt install apt-transport-https
sudo apt update
sudo apt install plexmediaserver
```

Verify that Plex is running:

```sh
sudo systemctl status plexmediaserver
```

### Firewall configuration

Create the file `/etc/ufw/applications.d/plexmediaserver` with the following ufw configuration:

```sh
[plexmediaserver]
title=Plex Media Server (Standard)
description=The Plex Media Server
ports=32400/tcp|3005/tcp|5353/udp|8324/tcp|32410:32414/udp

[plexmediaserver-dlna]
title=Plex Media Server (DLNA)
description=The Plex Media Server (additional DLNA capability only)
ports=1900/udp|32469/tcp

[plexmediaserver-all]
title=Plex Media Server (Standard + DLNA)
description=The Plex Media Server (with additional DLNA capability)
ports=32400/tcp|3005/tcp|5353/udp|8324/tcp|32410:32414/udp|1900/udp|32469/tcp
```

Update the profiles list:

```sh
sudo ufw app update plexmediaserver
```

Apply the firewall rules:

```sh
sudo ufw allow plexmediaserver-all
```

Check the status wit:

```sh
sudo ufw status verbose
```

### Configure Plex

We first create the directories which will content the files to serve and make `plex` user the owner of them:

```sh
sudo mkdir -p /opt/plexmedia/{movies,series}
sudo chown -R plex: /opt/plexmedia
```

You can know proceed with the server configuration: `http://YOUR_SERVER_IP:32400/web`.
