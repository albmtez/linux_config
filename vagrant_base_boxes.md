# Vagrant base box creation

[TOC]

---

Base boxes can be created from a vm. We're going to cover base boxes creation from Virtualbox and libvirt vms.

## Linux system configuration

Base linux configuration: partitioning, packages install, users, groups and certificates, needed to work with Vagrant.

### Disk configuration

* One disk mounted in /dev/sda.
* 20GB of disk space.
* Two primary partitions:
    * /dev/sda1 for /boot.
    * /dev/sda2 for LVM.
* LVM configuration:
    * PV: /dev/sda2 (20GB)
    * VG: systemvg (20GB)
    * LV:
        * root (17,5GB)
        * swap (2GB)

Partitions:

| Partition | File system               | mount point | type |
|-----------|---------------------------|-------------|------|
| /dev/sda1 |                           | /boot       | ext4 |
| /dev/sda2 | /dev/mapper/systemvg-root | /           | ext4 |
| /dev/sda2 | /dev/mapper/systemvg-swap | none        | swap |

### Configuration

#### Users and passwords

| username | password |
|----------|----------|
| root     | vagrant  |
| vagrant  | vagrant  |

#### Packages installed

The following packages have been installed:

* sudo
* parted (allows partition resizing)
* openssh-server
* gcc
* build-essential
* linux-headers

- Debian:
    apt install sudo parted openssh-server gcc build-essential linux-headers-amd64
- Centos:
    yum install sudo parted openssh-server gcc kernel-devel
    yum groupinstall 'Development Tools'
    yum install nano wget


#### Sudo configuration

**vagrant** user can use passwordless sudo.

Execute *visudo* command and paste the following line at the end of the file:

```sh
vagrant ALL=(ALL) NOPASSWD: ALL
```

#### SSH tweaks

In order to keep SSH speedy even when the machine is not connected to Internet, we set the **UseDNS** configuration to *no* in the SSH server configuration.

Edit the file ```/etc/ssh/ssh_config``` and add at the end:

```sh
UseDNS no
```

### Bash configuration

We are going to enable colorized ```ls``` and some alias.

Uncomment the following lines in ```/root/.bashrc``` file:

```sh
export LS_OPTIONS='--color_auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
```

### SSH access with insecure keypair

By default, Vagrant expects a "vagrant" user to SSH into the machine as. This user should be setup with the insecure keypair that Vagrant uses as a default to attempt to SSH.

Login with *vagrant* user and execute the following commands to add the insecure public key to authorized_keys:

```sh
mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
wget --no-check-certificate \
  https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub \
  -O /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
```

### Clean users' homes

Remove .bash_history and .bash_logout files from root and vagrant home dirs.

## Resize

config.vm.provision "shell", path: "resize_lvm.sh"

## Create virtualbox boxed

## Create libvirt boxed

open sudo vi /etc/ssh/sshd_config and change

PubKeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
PermitEmptyPasswords no
PasswordAuthentication no
restart ssh service using

 sudo service ssh restart
install additional development packages for the tools to properly compile and install

sudo apt-get install -y gcc build-essential linux-headers-server
do any change that you want and shutdown the VM . now , come to host machine on which guest VM is running and goto the /var/lib/libvirt/images/ and choose raw image in which you did the change and copy somewhere for example /test

cp /var/lib/libvirt/images/test.img  /test 
create two file metadata.json and Vagrantfile in /test do entry in metadata.json

{
  "provider"     : "libvirt",
  "format"       : "qcow2",
  "virtual_size" : 40
}
and in Vagrantfile

Vagrant.configure("2") do |config|
         config.vm.provider :libvirt do |libvirt|
         libvirt.driver = "kvm"
         libvirt.host = 'localhost'
         libvirt.uri = 'qemu:///system'
         end
config.vm.define "new" do |custombox|
         custombox.vm.box = "custombox"       
         custombox.vm.provider :libvirt do |test|
         test.memory = 1024
         test.cpus = 1
         end
         end
end
convert test.img to qcow2 format using

sudo qemu-img convert -f raw -O qcow2  test.img  ubuntu.qcow2
rename ubuntu.qcow2 to box.img

mv ubuntu.qcow2 box.img 
Note: currently,libvirt-vagrant support only qcow2 format. so , don't change the format just rename to box.img. because it takes input with name box.img by default.
create box

tar cvzf custom_box.box ./metadata.json ./Vagrantfile ./box.img 
add box to vagrant

vagrant box add --name custom custom_box.box
go to any directory where you want to initialize vagrant and run command bellow that will create Vagrant file

vagrant init custom
start configuring vagrant VM

vagrant up --provider=libvirt 
enjoy !!!




-------
imágenes:
  * debian 10
  * debian testing
  * centos 7
  * centos 8