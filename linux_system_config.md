# Linux configuration

[TOC]

---

## Remote server configuracion

### User configuration

We set the prompt, umask, coloured ls and aliases to have a known environment, despite the linux flavour used. We edit the file `~/.bashrc` adding the following contents:

```sh
export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
umask 077
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
```

### System update

Update the packages:

```sh
sudo apt update
sudo apt upgrade
```

Reboot if needed.

### Basic packages install

```sh
sudo apt install net-tools less htop curl
```

### Securing the machine

#### SSH port

Change ssh port editting the file `/etc/ssh/sshd_config`, uncommenting the following line and setting the desired port:

```sh
# Port 22
```

Restart the service:

```sh
sudo systemctl restart ssh
```

#### Disable ssh connection to root user

Edit the file `/etc/ssh/sshd_config` adding the flag:

```sh
PermitRootLogin no
```

Restart the service:

```sh
sudo systemctl restart ssh
```

#### Use normal user instead root

Change root password:

```sh
sudo passwd root
```

Create a normal user:

```sh
adduser username
```

We then set the umask, aliases and prompt, as described.

Disable root login through SSH editting the file `/etc/ssh/sshd_config`. Look for the value of `PermitRootLogin` and set to `no`.

Restart the service:

```sh
sudo system reboot ssh
```

#### Firewall

We are going to use Uncomplicated Firewall (<https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-debian-9>).

Install and configure:

```sh
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow <ssh_port>/tcp
sudo ufw enable
```

### Mosh

<https://www.digitalocean.com/community/tutorials/how-to-install-and-use-mosh-on-a-vps>

Use mosh to have a stable ssh connection.

Installation:

```sh
sudo apt install mosh
sudo ufw allow 60000:60010/udp
```

Use this command to connect to the server:

```sh
mosh --ssh="ssh -p <ssh_port>" username@hostname
```

### Prevent the server from going to sleep mode

To prevent the server from going to sleep mode automatically, we execute the following command:

```sh
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

To reenable auto suspend execute this command:

```sh
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### Boot in text mode

In order to always boot the server in text mode (no graphical interface lauched by default), execute this command:

```sh
sudo systemctl set-default multi-user.target
```

You can get the default behaviour with:

```sh
systemctl get-default
```

Finally, to reenable graphical mode execute this command:

```sh
sudo systemctl set-default graphical.target
```

## Base configuration

### Enable fractional scaling in Gnome

<https://www.omgubuntu.co.uk/2019/06/enable-fractional-scaling-ubuntu-19-04>

In order to enable screen scaling in values between 100% and 200%, execute the following command for `xorg`:

```sh
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
```

os this other command for `wayland`:

```sh
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

### Umask, $HOME permissions and bash configuration

We are going to set the default umask value to set restrictive permissions to directories and files created by the user.

Execute this command first:

```sh
systemctl --user edit dbus
```

A text editor is opened. Add the following to it:

```sh
[Service]
UMask=077
```

This will create the file `~/.config/systemd/user/dbus.service.d/override.conf`.

Now, let's set the umask in `~/.bashrc`, adding the following line to the end of the file:

```sh
umask 077
```

Now, we set the right permissions to $HOME and included directories:

```sh
chmod 700 $HOME
chmod 700 $HOME/*
```

Finally, we are going to add some aliases to bash editing the file `~/.bashrc`and looking for the line:

```sh
alias ll='ls -alF'
```

We must replace it with:

```sh
#alias ll='ls -alF'
alias ll='ls -l'
```

Logout and login to have these modifications applied.

### Install vanilla Gnome

<https://www.serverlab.ca/tutorials/linux/administration-linux/how-to-install-vanilla-gnome-on-ubuntu-18-04/>

To use Gnome vanilla desktop we have to first install `gnome-session`:

```sh
sudo apt install -y gnome-session
```

Then, we can set Gnome 3 vanilla as the default desktop:

```sh
sudo update-alternatives --config gdm3.css
```

Reboot. In the login screen we can now select Gnome vanilla as the session type.

### SSH

```sh
sudo apt install ssh
```

### Uncomplicated Firewall

Install ufw and ufw graphical interface:

```sh
sudo apt install ufw gufw
```

Activate the firewall with the default configuration:

```sh
sudo ufw enable
```

If you have troubles to start gfuw, execute the following command:

```sh
xhost +
```

### Wakeup from USB devices

By default, when the system is suspended it can't be waked up from the keyboard or mous. To allow waking up from these devices we have first to identify the device with `lsusb`:

![lsusb](attachments/lsusb.png)

We create the file `90-keyboardwakeup.rules`:

```sh
sudo nano /etc/udev/rules.d/90-keyboardwakeup.rules
```

with the following line:

```sh
SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c52b" RUN+="/bin/sh -c 'echo enabled > /sys$env{DEVPATH}/../power/wakeup'"
```

### Powertop

```sh
sudo apt install powertop
```

### Htop

```sh
sudo apt install htop
```

### Laptop Mode Tools

```sh
sudo apt install laptop-mode-tools
```

### ACPI

```sh
sudo apt install acpi
```

To check the battery status execute the following command:

```sh
acpi -V
```

### Wavemon

```sh
sudo apt install wavemon
```

### TRIM

Let's enable automatic TRIM executed weekly:

```sh
sudo cp /usr/share/doc/util-linux/examples/fstrim.{service,timer} /etc/systemd/system
sudo systemctl enable fstrim.timer
```

To check the status of a mounting point (/ in the example below):

```sh
sudo fstrim -v /
```

To force the TRIM:

```sh
sudo fstrim -av
```

### exFAT partitions support

```sh
sudo apt install exfat-fuse exfat-utils
```

### Hardwarelister

```sh
sudo apt install lshw lshw-gtk
```

### Compression tools

```sh
sudo apt install unrar p7zip unace zip unzip
```

### WOL and network tools

```sh
sudo apt install wakeonlan ethtool bridge-utils net-tools
```

### Terminator

```sh
sudo apt install terminator
```

### Screenfetch

```sh
sudo apt install screenfetch
```

### Neofetch

```sh
sudo apt install neofetch
```

## Gnome desktop configuration

### Online accounts

Add Gmain account.

### Energy

Enable autosuspend after 45 minutes.
Power button action: Shutdown.

### Files (Nautilus)

Settings:

* Vistas
  * Activar “Colocar las carpetas antes que los archivos”
  * Activar “Permitir expandir las carpetas”
* Comportamiento
  * Activar “Mostrar una acción para crear enlaces simbólicos”
  * Activar “Archivos de texto ejecutables” - “Preguntar qué hacer”
* Columnas de la lista
  * Marcar Propietario y Permisos
* Buscar y previsualizar
  * Mostrar miniaturas - Todos los archivos
  * Contar el número de elementos - Todas las carpetas

### GEdit (settings and plugins)

Settings:

* Ver:
  * Mostrar números de línea
  * Mostrar mapa de vista previa
  * Resaltar la línea actual
  * Resaltar parejas de corchetes
* Editor:
  * Anchura del tabulador 4
  * Activar sangría automática
* Complementos
  * Comentar código
  * Comple  tar paréntesis
  * Consola Python
  * Dibujar espacios
  * Git

### Gnome Tweak Tool

Already installed. If not, install executing:

```sh
sudo apt install gnome-tweak-tool
```

Settings:

* Apariencia
  * Temas - Aplicaciones: Yaru-dark
* Barra superior
  * Porcentaje de la batería
  * Mostrar la fecha
  * Mostrar el número de la semana

### Alacarte

```sh
sudo apt install alacarte
```

### Gnome extensions

<https://extensions.gnome.org/>

Enable Gnome Shell Integration form Chrome:

```sh
sudo apt install chrome-gnome-shell
```

* system-monitor (<https://extensions.gnome.org/extension/120/system-monitor/>)
Required dependencies:

```sh
sudo apt install gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-cogl-1.0 gir1.2-clutter-1.0
```

* Caffeine:<https://extensions.gnome.org/extension/517/caffeine/>
* TopIcons: <https://extensions.gnome.org/extension/495/topicons/>
* TopIconsFix: <https://extensions.gnome.org/extension/1674/topiconsfix/>
* TopIcons Plus: <https://extensions.gnome.org/extension/1031/topicons/>
* Lock Keys: <https://extensions.gnome.org/extension/36/lock-keys/>
* Status Area Horizontal Spacing: <https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/>
* Refresh Wifi Connections: <https://extensions.gnome.org/extension/905/refresh-wifi-connections/>
* Turn off Display: <https://extensions.gnome.org/extension/897/turn-off-display/>
* Suspend Button: <https://extensions.gnome.org/extension/826/suspend-button/>
* Freon: <https://extensions.gnome.org/extension/841/freon/>
* gTile: <https://extensions.gnome.org/extension/28/gtile/>
* Sound Input & Output Device Chooser: <https://extensions.gnome.org/extension/906/sound-output-device-chooser/>
* Disconnect Wifi: <https://extensions.gnome.org/extension/904/disconnect-wifi/>
* Screenshot Tool: <https://extensions.gnome.org/extension/1112/screenshot-tool/>
* Log Out Button: <https://extensions.gnome.org/extension/1143/logout-button/>
* Touchpad Indicator: <https://extensions.gnome.org/extension/131/touchpad-indicator/>
* Multi Monitor add-on: <https://extensions.gnome.org/extension/921/multi-monitors-add-on/>
* Alternate Tab: <https://extensions.gnome.org/extension/15/alternatetab/>

### Solaar

```sh
sudo apt install solaar solaar-gnome3
```

## Applications install

### Chrome

Download the install package from the Chrome web site: <https://www.google.es/chrome/browser/desktop/>

The package install adds the needed repositories to apt in order to install futre updates.

### Handbrake

```sh
sudo apt install handbrake
```

### Drobox

Install the required packages:

```sh
sudo apt install libpango1.0-0 libpangox-1.0-0
```

Download the installer from the Dropbox web site: <https://www.dropbox.com/install>

### Spotify

Download the installer from the Spotify web site and install.

### Skype

Download the installer from the Skype web site and install.

### WebTorrent Desktop

Install the required packages:

```sh
sudo apt install gconf2
```

Download the installer from: <https://webtorrent.io/desktop/>

### Vlc

```sh
sudo apt install vlc
```

### GParted

```sh
sudo apt install gparted
```

### EasyTag

```sh
sudo apt install easytag
```

### Transmission

```sh
sudo apt install transmission
```

### Filezilla

```sh
sudo apt install filezilla
```

### Graphical design applications

* Easy painting: MyPaint
* Image editor: GIMP
* Vectorial design: Inkscape
* RAW images editting: RawTherapee

```sh
sudo apt install mypaint gimp inkscape rawtherapee
```

### Audacity and Ardour for audio edition

```sh
sudo apt install audacity ardour
```

### Pitivi for video edition

```sh
sudo apt install pitivi
```

### Blender for 3D design

```sh
sudo apt install blender
```
