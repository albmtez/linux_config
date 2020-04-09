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
