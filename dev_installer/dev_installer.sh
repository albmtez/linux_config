#!/bin/bash

script_name=$0
DEV_BASE=$HOME/dev
CODE_BASE=$HOME/code

function usage {
  echo "Usage: $script_name <bundle_or_package_name>"
  echo "    Software:"
  echo "        base_config      - Directories are created and shell configured"
  echo "          dirs           - Directories creation"
  echo "          shell_conf     - Shell configuration, adding environment variables and executables to PATH"
  echo "        fundamentals     - Fundamental development software install"
  echo "          base_sw        - Install base software from apt repository (root pwd required)"
  echo "          git            - Installs git scm. You'll have to select the version to install"
  echo "        development      - Development languages and tools"
  echo "          go             - Installs the latest version of Golang"
  echo "          dart           - Install the latest version of dart"
  echo "          python         - Installs python. You'll have to select the version to install"
  echo "          node           - Installs the latest version of Node JS"
  echo "          maven          - Installs the latest version of Maven"
  echo "          ant            - Installs the latest version of Ant"
  echo "        virtualization   - Virtualization tools"
  echo "          kvm            - KVM"
  echo "          virtualbox     - Virtualbox"
  echo "          vagrant        - Vagrant"
  echo "        docker_all       - Docker engine and tools"
  echo "          docker         - Docker engine Community"
  echo "          docker-compose - Docker compose"
  echo "          docker-machine - Docker machine"
  echo "        kubernetes_all   - Kubernetes tools"
  echo "          minikube       - Minikube"
  echo "          kubectl        - Kubectl"
  echo "          kubectx        - Kubectx"
  echo "          kubens         - Kubens"
  echo "          k3sup          - K3sup 'ketchup'"
  echo "          k3d            - K3D"
  echo "          kind           - Kind"
  echo "          knative        - Knative CLI"
  echo "        provisioning     - Provision tools"
  echo "          ansible        - Ansible"
  echo "          puppet         - Puppet"
  echo "          terraform      - Terraform"
  echo "          tfm_proxmox    - Terraform provider for Proxmox"
}

function dirs_creation {
  echo "Directories creation..."
  echo "  $DEV_BASE"
  echo "  |- bin"
  echo "  $CODE_BASE"
  echo "  |- go"
  echo "  |  |- src"
  echo "  |  |- pkg"
  echo "  |  |- bin"
  echo "  |- tmp"

  # Main directories
  mkdir -p $DEV_BASE
  mkdir -p $DEV_BASE/bin
  mkdir -p $CODE_BASE
  mkdir -p $CODE_BASE/tmp

  # Go directories
  mkdir -p $CODE_BASE/go/src
  mkdir -p $CODE_BASE/go/pkg
  mkdir -p $CODE_BASE/go/bin
}

function environment_config {
  cat >$DEV_BASE/dev_profile <<EOL
# Dev environment configuration

# Dev base dir
export DEV_BASE=\$HOME/dev

# Code base dir
export CODE_BASE=\$HOME/code

# Binaries dir added to PATH
export PATH=\$DEV_BASE/bin:\$PATH

# Git config
export GIT_HOME=\$DEV_BASE/git/default
export PATH=\$GIT_HOME/bin:\$PATH

# Python config
export PYTHONPATH=\$DEV_BASE/python/default
export PATH=\$PYTHONPATH/bin:\$PATH

# Go config
export GOROOT=\$DEV_BASE/go/default
export GOPATH=\$CODE_BASE/go
export PATH=\$GOROOT/bin:\$PATH

# NodeJS config
export NODEJS_HOME=\$DEV_BASE/node/default/bin
export PATH=\$NODEJS_HOME:\$PATH

# Maven config
export MAVEN_HOME=\$DEV_BASE/apache-maven/default
export PATH=\$MAVEN_HOME/bin:\$PATH

# Ant config
export ANT_HOME=\$DEV_BASE/apache-ant/default
export PATH=\$ANT_HOME/bin:\$PATH

# Aliases
alias k=kubectl
alias kcc=kubectx
alias ns=kubens
EOL

  cp $script_name $DEV_BASE
}

function base_sw {
  echo "Base software installation"
  echo "You'll be required to enter root password"
  sudo apt update
  sudo apt install -y build-essential git cvs subversion mercurial maven ant etckeeper \
                        git-cvs git-svn subversion-tools openjdk-11-jdk \
                        dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev \
                        libssl-dev asciidoc xmlto docbook2x install-info \
                        libffi-dev
}

function git_install {
  echo "Git scm installation"
  tmpDir=$(mktemp -d)
  cd $tmpDir
  git clone https://github.com/git/git.git
  cd git
  git fetch --tags
  tag=$(git tag -l --sort=-v:refname | grep -oP '^v[0-9\.]+$' | head -n 1)

  # Check if already installed
  [ -d $DEV_BASE/git/git-$tag ] && echo "Git version ${tag} already installed!" && rm -rf $tmpDir && unset tmpDir && exit 1

  git checkout $tag -b version-to-install
  mkdir $DEV_BASE/git
  rm -rf $DEV_BASE/git/git-$tag
  make configure
  ./configure --prefix=$DEV_BASE/git/git-$tag
  make all
  make install
  rm -f $DEV_BASE/git/default
  ln -s $DEV_BASE/git/git-$tag $DEV_BASE/git/default
  rm -rf $tmpDir
  unset tmpDir
}

function go_install {
  echo "Golang installation"
  
  # Find latest version
  echo "Finding latest version of Go for AMD64..."
  url="$(wget -qO- https://golang.org/dl/ | grep -oP '\/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )"
  latest="$(echo $url | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"

  # Check if already installed
  [ -d $DEV_BASE/go/go-"${latest}" ] && echo "Go version ${latest} already installed!" && exit 1

  # Download Go
  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  echo "Downloading latest Go for AMD64: ${latest}"
  wget --quiet --continue --show-progress "https://golang.org${url}"
  unset url

  mkdir -p $DEV_BASE/go
  tar -C $DEV_BASE/go -xzf go"${latest}".linux-amd64.tar.gz
  mv $DEV_BASE/go/go $DEV_BASE/go/go-"${latest}"
  rm -f $DEV_BASE/go/default
  ln -s $DEV_BASE/go/go-"${latest}" $DEV_BASE/go/default
  unset latest
  rm -rf ${tmpDir}
  unset tmpDir
}

function dart_install {
  echo "Dart installation"
  echo "You'll be required to enter root password"

  sudo apt-get update
  sudo apt-get install apt-transport-https
  sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
  sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
  sudo apt update
  sudo apt install -y dart
}

function python_install {
  echo "Python installation"
  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  git clone https://github.com/python/cpython.git
  cd cpython
  git fetch --tags
  tag=$(git tag -l --sort=-v:refname | grep -oP '^v[0-9\.]+$' | head -n 1)

  # Check if already installed
  [ -d $DEV_BASE/python/python-$tag ] && echo "Python version ${tag} already installed!" && rm -rf $tmpDir && unset tmpDir && exit 1

  git checkout $tag -b version-to-install
  mkdir $DEV_BASE/python
  rm -rf $DEV_BASE/python/python-$tag
  ./configure --prefix=$DEV_BASE/python/python-$tag
  make
  make install
  rm -f $DEV_BASE/python/default
  ln -s $DEV_BASE/python/python-$tag $DEV_BASE/python/default
  rm -rf ${tmpDir}
  unset tmpDir
}

function node_install {
  echo "Node JS installation"

  # Find latest version
  echo "Finding latest version of NodeJS for AMD64..."
  url="$(wget -qO- https://nodejs.org/dist/latest/ | grep -oP 'node-v([0-9\.]+)\-linux-x64\.tar\.gz' | head -n 1 )"
  latest="$(echo $url | grep -oP 'node-v[0-9\.]+' | grep -oP '[0-9\.]+')"

  # Check if already installed
  [ -d $DEV_BASE/node/node-v"${latest}" ] && echo "Node version ${latest} already installed!" && exit 1

  # Download Node
  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  echo "Downloading latest Node for AMD64: ${latest}"
  wget --quiet --continue --show-progress https://nodejs.org/dist/latest/"${url}"
  unset url

  mkdir -p $DEV_BASE/node
  tar -C $DEV_BASE/node -xzf node-v"${latest}"-linux-x64.tar.gz
  mv $DEV_BASE/node/node-v"${latest}"-linux-x64 $DEV_BASE/node/node-v"${latest}"
  rm -f $DEV_BASE/node/default
  ln -s $DEV_BASE/node/node-v"${latest}" $DEV_BASE/node/default

  rm -rf ${tmpDir}
  unset tmpDir
}

function maven_install {
  echo "Maven installation"

  # Find latest version
  echo "Finding latest version of Apache Maven for AMD64..."
  latest="$(wget -qO- https://dlcdn.apache.org/maven/maven-3/ | grep -oP '[0-9\.]+/<' | grep -oP '[0-9\.]+' | tail -n 1)"

  # Check if already installed
  [ -d $DEV_BASE/apache-maven/apache-maven-"${latest}" ] && echo "Apache Maven version ${latest} already installed!" && exit 0

  # Download Apache Maven
  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  echo "Downloading latest Apache Maven for AMD64: ${latest}"
  wget --quiet --continue --show-progress https://dlcdn.apache.org/maven/maven-3/"${latest}"/binaries/apache-maven-"${latest}"-bin.tar.gz
  unset url

  mkdir -p $DEV_BASE/apache-maven
  tar -C $DEV_BASE/apache-maven -xzf apache-maven-"${latest}"-bin.tar.gz
  rm -f $DEV_BASE/apache-maven/default
  ln -s $DEV_BASE/apache-maven/apache-maven-"${latest}" $DEV_BASE/apache-maven/default

  rm -rf ${tmpDir}
  unset tmpDir
}

function ant_install {
  echo "Ant installation"

  # Find latest version
  echo "Finding latest version of Apache Ant for AMD64..."
  latest="$(wget -qO- http://apache.uvigo.es//ant/binaries/ | grep -oP 'apache-ant-([0-9\.]+)-bin.tar.gz<' | grep -oP 'ant-[0-9\.]+' | grep -oP '[0-9\.]+' | sort --version-sort | tail -n 1)"

  # Check if already installed
  [ -d $DEV_BASE/apache-ant/apache-ant-"${latest}" ] && echo "Apache Ant version ${latest} already installed!" && exit 0

  # Download Apache Ant
  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  echo "Downloading latest Apache Ant for AMD64: ${latest}"
  wget --quiet --continue --show-progress http://apache.uvigo.es//ant/binaries/apache-ant-"${latest}"-bin.tar.gz
  unset url

  mkdir -p $DEV_BASE/apache-ant
  tar -C $DEV_BASE/apache-ant -xzf apache-ant-"${latest}"-bin.tar.gz
  rm -f $DEV_BASE/apache-ant/default
  ln -s $DEV_BASE/apache-ant/apache-ant-"${latest}" $DEV_BASE/apache-ant/default

  rm -rf ${tmpDir}
  unset tmpDir
}

function kvm_install {
  echo "KMV install"

  # Install packages from apt repositories
  echo "You'll be required to enter root password"
  sudo apt install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-top virt-manager seabios qemu-utils ovmf

  # Add user to libvirt and libvirt-qemu groups
  user=$(whoami)
  sudo usermod -a -G libvirt $user
  sudo usermod -a -G libvirt-qemu $user
  unset user
}

function virtualbox_install {
  echo "Virtualbox install"
  echo "You'll be required to enter root password"

  # Install requierd packages
  # Add packages to apt sources
  # Add repo keys
  # Install virtualbox package
  # Add user to vboxusers group
  # Recompile the kernel moduoe an install it
  user=$(whoami)
  sudo apt -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  release_name=$(lsb_release -cs)
  sudo add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $release_name contrib"
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
  sudo apt update
  sudo apt upgrade -y
  sudo apt install -y virtualbox-6.1
  sudo usermod -a -G vboxusers $user
  unset user
  unset release_name
}

function vagrant_install {
  echo "Vagrant install"
  echo "You'll be required to enter root password"

  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install vagrant
}

function docker_install {
  echo "Docker install"
  echo "You'll be required to enter root password"

  # Uninstall old versions.
  sudo apt remove -y docker docker-engine docker.io containerd runc

  # Install the required packages to allow apt to use a repository over HTTPS
  sudo apt update
  sudo apt install ca-certificates curl gnupg lsb-release

  # Add Docker's official GPG key
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo $DISTRO
  # Set up the repository
  if [ $DISTRO = "Ubuntu" ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi
  if [ $DISTRO = "Debian" ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi

  # Install Docker engine
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Add the user to docker group.
  sudo usermod -aG docker $(whoami)
}

function docker_compose_install {
  echo "Docker compose install"

  version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
  echo "Installing docker compose version ${version}"
  curl -L "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o $DEV_BASE/bin/docker-compose
  chmod +x $DEV_BASE/bin/docker-compose
  unset version
}

function docker_machine_install {
  echo "Docker machine install"

  version=$(curl -s https://api.github.com/repos/docker/machine/releases/latest | grep 'tag_name' | cut -d\" -f4)
  echo "Installing docker machine version ${version}"
  curl -L https://github.com/docker/machine/releases/download/${version}/docker-machine-$(uname -s)-$(uname -m) -o $DEV_BASE/bin/docker-machine
  chmod +x $DEV_BASE/bin/docker-machine
  unset version
}

function minikube_install {
  echo "Minikube install"

  curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o $DEV_BASE/bin/minikube
  chmod +x $DEV_BASE/bin/minikube
}

function kubectl_install {
  echo "kubectl install"

  curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o $DEV_BASE/bin/kubectl
  chmod +x $DEV_BASE/bin/kubectl
}

function kubectx_install {
  echo "kubectx install"

  git clone https://github.com/ahmetb/kubectx.git
  cp kubectx/kubectx $DEV_BASE/bin
  rm -rf kubectx
}

function kubens_install {
  echo "kubens install"

  git clone https://github.com/ahmetb/kubectx.git
  cp kubectx/kubens $DEV_BASE/bin
  rm -rf kubectx
}

function k3sup_install {
  echo "k3sup install"

  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  curl -sLS https://get.k3sup.dev | sh
  mv k3sup $DEV_BASE/bin
  rm -rf ${tmpDir}
  unset tmpDir
}

function k3d_install {
  echo "k3d install"
  echo "You'll be required to enter root password"

  USR=$(whoami)
  GRP=$(id -g -n)
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  sudo mv /usr/local/bin/k3d $DEV_BASE/bin
  sudo chown $USR:$GRP $DEV_BASE/bin/k3d
}

function kind_install {
  echo "kind install"

  url=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep "browser_download_url" | grep linux-amd64\" | awk '{print $2}' | tr -d \")
  wget $url
  mv kind-linux-amd64 $DEV_BASE/bin/kind
  chmod +x $DEV_BASE/bin/kind
  unset url
}

function knative_install (
  echo "Knative CLI install"

  url=$(curl -s https://api.github.com/repos/knative/client/releases/latest | grep "browser_download_url" | grep linux-amd64 | awk '{print $2}' | tr -d \")
  wget $url
  mv kn-linux-amd64 $DEV_BASE/bin/kn
  chmod +x $DEV_BASE/bin/kn
  unset url
)

function ansible_install {
  echo "Ansible install"
  echo "You'll be required to enter root password"

  sudo apt update
  sudo apt install -y ansible
}

function puppet_install {
  echo "Puppet install"
  echo "You'll be required to enter root password"

  sudo apt update
  sudo apt install -y puppet
}

function terraform_install {
  echo "Terraform install"

  # Get the latest version
  latest=$(wget -qO- https://releases.hashicorp.com/terraform/ | grep -oP 'terraform_[0-9\.]+<' | grep -oP 'terraform_[0-9.]+' | grep -oP '[0-9\.]+' | head -n 1)

  # Download zip file
  tmpDir=$(mktemp -d)
  cd ${tmpDir}
  echo "Downloading latest Terraform version: ${latest}"
  wget --quiet --continue --show-progress https://releases.hashicorp.com/terraform/"${latest}"/terraform_"${latest}"_linux_amd64.zip
  unzip "${tmpDir}"/terraform_"${latest}"_linux_amd64.zip -d ${tmpDir}
  inst_ver=""
  [ -f $DEV_BASE/bin/terraform ] && inst_ver=$($DEV_BASE/bin/terraform -version)
  latest_ver=$(${tmpDir}/terraform -version)
  if [ "${inst_ver}" = "${latest_ver}" ]; then
    echo "Terraform version ${latest} already installed"
    unset inst_ver
    unset latest_ver
    rm -rf ${tmpDir}
    exit 1
  fi
  echo "Installing Terraform ${latest}"
  cp ${tmpDir}/terraform $DEV_BASE/bin
  chmod 700 $DEV_BASE/bin/terraform
  rm -rf ${tmpDir}
  unset latest
}

function tfm_proxmox_install {
  cd $CODE_BASE/tmp
  git clone https://github.com/Telmate/terraform-provider-proxmox.git
  cd terraform-provider-proxmox
  go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
  go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
  make
  mkdir ~/.terraform.d/plugins
  cp bin/terraform-provider-proxmox ~/.terraform.d/plugins
  cp bin/terraform-provisioner-proxmox ~/.terraform.d/plugins
  cd $CODE_BASE/tmp
  rm -rf terraform-provider-proxmox
}

[[ "$@" = "" ]] && usage && exit 1
[ "$#" -ne 1 ] && echo "Error: Wrong number of arguments" && usage && exit 1

# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" = "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" = "" ] && export DISTRO=$UNAME
unset UNAME

case "$1" in
  "base_config")
    dirs_creation
    environment_config
    ;;
  "fundamentals")
    base_sw
    git_install
    ;;
  "dirs")
    dirs_creation
    ;;
  "shell_conf")
    environment_config
    ;;
  "base_sw")
    base_sw
    ;;
  "git")
    git_install
    ;;
  "development")
    go_install
    dart_install
    python_install
    node_install
    maven_install
    ant_install
    ;;
  "go")
    go_install
    ;;
  "dart")
    dart_install
    ;;
  "python")
    python_install
    ;;
  "node")
    node_install
    ;;
  "maven")
    maven_install
    ;;
  "ant")
    ant_install
    ;;
  "virtualization")
    kvm_install
    virtualbox_install
    vagrant_install
    ;;
  "kvm")
    kvm_install
    ;;
  "virtualbox")
    virtualbox_install
    ;;
  "vagrant")
    vagrant_install
    ;;
  "docker_all")
    docker_install
    docker_compose_install
    docker_machine_install
    ;;
  "docker")
    docker_install
    ;;
  "docker-compose")
    docker_compose_install
    ;;
  "docker-machine")
    docker_machine_install
    ;;
  "kubernetes_all")
    minikube_install
    kubectl_install
    kubextx_install
    kubens_install
    k3sup_install
    k3d_install
    kind_install
    knative_install
    ;;
  "minikube")
    minikube_install
    ;;
  "kubectl")
    kubectl_install
    ;;
  "kubectx")
    kubectx_install
    ;;
  "kubens")
    kubens_install
    ;;
  "kubectx")
    kubectx_install
    ;;
  "kubens")
    kubens_install
    ;;
  "k3sup")
    k3sup_install
    ;;
  "k3d")
    k3d_install
    ;;
  "kind")
    kind_install
    ;;
  "knative")
    knative_install
    ;;
  "provisioning")
    ansible_install
    puppet_install
    terraform_install
    tfm_proxmox_install
    ;;
  "ansible")
    ansible_install
    ;;
  "puppet")
    puppet_install
    ;;
  "terraform")
    terraform_install
    ;;
  "tfm_proxmox")
    tfm_proxmox_install
    ;;
  *)
    echo "Error: Bundle or package name invalid" && usage && exit 1
    ;;
esac

exit 0

