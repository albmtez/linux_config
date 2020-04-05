# Develop environment

[TOC]

---

## Intro to dev_installer script

This shellscript manages the installation, update and remove of development software and toolset into a linux system (tested with Ubuntu 19.10).

Some of the applications/tools are installed using the package manager apt and are accessible for all users. Besides, if there an installation in the home user directory is prefered and used if possible. In this case, the application is only configured and available for the user.

The software is organized in the following **bundles** (by type of software):

- **base_config**: Creates the basic directory structure, adds a script that congigures the shell with the need environment variables to have all the applications availables and ready to use. Finally, a bunch of applications is installed.
- **development**: Installs the needed software to develep in different languages.
- **virtualization**: Virtualization tools and hypervisors.
- **docker_all**: Installs and configures Docker engine, some docker tools and kubernetes.
- **provisioning**: Some tools for managing configuration and provisioning are installed and configured.

Each *bundle* is composed of several applications or tools, that can be installed separately, providing its name. If the *bundle* name is provided, all the software included will be installed.

## Usage

```text
Usage: ./dev_installer.ssh <bundle_or_package_name>
    Software:
        base_config      - Directories are created and all base software is installed (root pwd required)
          dirs           - Directories creation
          shell_conf     - Shell configuration, adding environment variables and executables to PATH
          base_sw        - Install base software from apt repository (root pwd required)
          git            - Installs git scm. You'll have to select the version to install
        development      - Development languages and tools
          go             - Installs the latest version of Golang
          dart           - Install the latest version of dart
          python         - Installs python. You'll have to select the version to install
          node           - Installs the latest version of Node JS
          maven          - Installs the latest version of Maven
          ant            - Installs the latest version of Ant
        virtualization   - Virtualization tools
          kvm            - KVM
          virtualbox     - Virtualbox
          vagrant        - Vagrant
        docker_all       - Docker engine and tools
          docker         - Docker engine Community
          docker-compose - Docker compose
          docker-machine - Docker machine
          minikube       - Minikube
          kubectl        - Kubectl
       provisioning      - Provision tools
          ansible        - Ansible
          puppet         - Puppet
          terraform      - Terraform
```

## Bundles

### base_config

These are the packages included in this bundle:

#### dirs

The software is installed in the `$HOME` user's directory. Some directories are created:

```sh
$HOME/dev
  |- bin
  |- code
  |  |- go
  |  |  |- src
  |  |  |- pkg
  |  |  |- bin
  |- tmp
```

|Directory|Use|
|---------|---|
|bin      |Contains binaries and scripts|
|go       |Used to contain the recommended structure of the Go path|
|tmp      |Temporary directory|

This option simply creates this directory structure in the user's `$HOME` directory.

#### shell_conf

A file named `dev_profile` is placed in `$HOME/dev` directory, containing the needed configuration for your shell in order to configure all the installed software and make it available in your `$PATH`.

You simply have to source this file in the configuration file of your prefered shell.

#### base_software

Installs a base development software from apt.

*You'll be required to enter the root password in order to install the packages using sudo.*

These are the packages installed:

*build-essential
git-all
cvs
subversion
mercurial
maven
ant
etckeeper
git-cvs
git-svn
subversion-tools
openjdk-11-jdk
dh-autoreconf
libcurl4-gnutls-dev
libexpat1-dev
gettext
libz-dev
libssl-dev
asciidoc
xmlto
docbook2x
install-info
libffi-dev*

#### git

Installs git in `$HOME/dev/git`. If this package is installed, it'll override the system installation of git.

You'll be asked to enter the version you desire to be installed.

The installation is made compiling and installing the source code.

### development

This bundle includes the following packages that install different languages development tools.

#### go

Latest stable version of go.

#### dart

Latest stable version of dart.

#### python

You'll be required to enter the version of Python to be installed.

The installation is made compiling and installing the source code.

#### node

Latest stable version of NodeJS.

#### maven

Latest stable version of Apache Maven.

#### ant

Latest stable version of Apache Ant.

### virtualization

This bundle includes the install of some hypervisors and tools for creation and magement of VMs.

#### kvm

qemu and kvm are installed and configured (tools like virsh are installed too).

The user is added to the groups `libvirt` and `libvirt-qemu` in order to be able to use the hypervisor.

The installation is made using apt.

#### virtualbox

Latest version of Virtualbox 6.1 is installed from the official repositories.

The user is added to the group `vboxusers`.

#### vagrant

Latest version package of Vagrant is installed from the official repo.

### docker_all

This bundle install the Docker engine and the needed tools to use Docker and Kubernetes.

#### docker

Install the Docker Engine + client from the official repository packages.

The user is added to `docker` group, so that he'll be able to use docker without sudo.

#### docker-compose

Latest version of docker-compose is installed in `$HOME/dev/bin` from the official site.

#### docker-machine

Latest version of docker-machine is installed in `$HOME/dev/bin` from the official site.

#### minikube

Latest version of minikube is installed in `$HOME/dev/bin` from the official site.

#### kubectl

Latest version of kubectl is installed in `$HOME/dev/bin` from the official site.

### provisioning

This bundle install provisioning and version management software.

#### ansible

Latest version of ansible is installed from the offician repository.

#### puppet

Puppet is installed from apt.

#### terraform

Latest version of Terraform is installed from the official site.