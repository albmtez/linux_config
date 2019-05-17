# Dev cloud environment
Instalación de un entorno de desarrollo cloud.
Basado en **Debian 9**.

## Configuración básica del sistema
*(info: https://www.digitalocean.com/community/tutorials/initial-server-setup-with-debian-9)*

Cambiamos el prompt, umask, coloreado en ls y alias, editando el archivo ~/.bashrc:

```
export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
umask 077
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
```

Actualizamos el sistema:

```
# apt update
# apt upgrade
```

Cambiamos el puerto de escucha de sshd:
- Editamos el archivo */etc/ssh/sshd_config*, descomentando la línea siguiente, poniendo el puerto que deseemos:
```
# Port 22
```
- Reiniciamos:
```	
# /etc/init.d/ssh restart
```

Cambiamos la password de root:
```
# passwd root
```

Creamos un nuevo usuario:
```
# adduser username
```

Le ponemos *'umask 077'* y habilitamos los alias editando el archivo *.bashrc*.

Deshabilitamos el acceso por ssh al usuario root, editando el archivo *'/etc/ssh/sshd_config'*. Buscamos el valor de **PermitRootLogin**, lo ponemos a **no** y reiniciamos el servicio.
```
# /etc/init.d/ssh restart
```

Instalamos algunos paquetes básicos:
```
# apt install net-tools less htop curl
```

## Configuración firewall con ufw
*(https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-debian-9)*

Instalamos y configuramos UFW:
```
# apt install ufw
# ufw default deny incoming
# ufw default allow outgoing
# ufw allow 22022/tcp
# ufw enable
```

## Instalación mosh
*(https://www.digitalocean.com/community/tutorials/how-to-install-and-use-mosh-on-a-vps)*

```
# apt install mosh
# ufw enable 60000:61000/udp
```

Nos conectamos con:
```
$ mosh --ssh="ssh -p ssh_port" username@host
```

## Preparación del directorio base

Vamos a crear el directorio base:

```
$ mkdir $HOME/dev
```

Dentro de este directorio iremos creando subdirectorios y archivos. Por ahora, crearemos un directorio para el código fuente y un directorio temporal:

```
mkdir $HOME/dev/code
mkdir $HOME/dev/tmp
```

## Configuración del entorno

Haremos la configuración del entorno usando variables de entorno. Para ello, usaremos un archivo `bash_profile` que contendrá todas las definiciones.

Creamos el archivo en `$HOME/dev`:

```
touch $HOME/dev/bash_profile
```

Y lo inicializamos con el siguiente contenido:

```
# Dev environment configuration

# Dev base dir
export DEV_BASE=$HOME/dev
```

## Instalación de herramientas base desde el repositorio de paquetes

Instalamos los siguientes paquetes por apt:
- Build essential
- Subversion
- CVS
- Git (con los paquetes de integración con subversion y CVS)
- Ant
- Maven
- Linux Headers
- OpenJDK 8 y OpenJDK 11

Algunas de estas herramientas serán "sustituidas" por versiones concretas más adelante.

Para instalarlas, ejecutamos el comando:

```
# apt install build-essential git-all cvs subversion mercurial maven ant etckeeper git-cvs git-svn subversion-tools openjdk-8-jdk
```

## Git

*(fuente: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)*

Podemos instalar git desde el gestor de paquetes apt con `sudo apt install git-all`. Sin embargo, haremos la instalación desde el código fuente para tener control sobre la versión que utilizamos.

Para compilar el código fuente de git necesitamos instalar unos paquetes:

```
# apt install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto docbook2x install-info
```

Recuperamos el código fuente y descomprimimos:

```
$ wget https://github.com/git/git/archive/v2.21.0.tar.gz -P $DEV_BASE/tmp
$ cd $DEV_BASE/tmp
$ tar xzvf v2.21.0.tar.gz
```

Ya podemos compilar e instalar. Haremos la instalación en $HOME/dev/git/git-2-19.1.

```
$ mkdir $DEV_BASE/git
$ cd git-2.19.1
$ make configure
$ ./configure --prefix=$DEV_BASE/git/git-2.21.0
$ make all
$ make install
```

Finalmente, establecemos esta versión como la que usaremos por defecto en el entorno de desarrollo:

```
$ ln -s $DEV_BASE/git/git-2.21.0 $DEV_BASE/git/default
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Git config
export GIT_HOME=$DEV_BASE/git/default
export PATH=$GIT_HOME/bin:$PATH
```

## Python

Instalamos Python desde el código fuente. Primero instalamos el paquete libffi-dev` necesario para la compilación:

```
$ sudo apt install libffi-dev
```

Compilamos e instalamos:

```
$ mkdir $DEV_BASE/python
$ wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz -P $DEV_BASE/tmp
$ cd $DEV_BASE/tmp
$ tar xzvf Python-3.7.3.tgz
$ cd Python-3.7.3
$ ./configure --prefix=$DEV_BASE/python/python-3.7.3
$ make
$ make install
```

Creamos el enlace `default` a la versión que queremos usar por defecto *(https://bugs.python.org/issue30090)*:

```
$ ln -s $DEV_BASE/python/python-3.7.3 $DEV_BASE/python/default
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Python config
export PYTHONPATH=$DEV_BASE/python/default
export PATH=$PYTHONPATH/bin:$PATH
```

Hacemos un sourcing de la configuración:

```
$ source $DEV_BASE/bash_profile
```

### Creación de entornos virtuales

Para crear entornos virtuales utiliamos `venv`. Creamos un directorio para el código fuente Python en nuestro entorno y creamos un entorno virtual de base con Python 3:

```
$ mkdir $DEV_BASE/code/python
$ cd $DEV_BASE/code/python
$ python3 -m venv env-python-3.7.3
```

## Golang

*Al hacer los untar, utilizaremos la opción **--no-same-permissions** para que tome el umask del usuario*

```
$ mkdir $DEV_BASE/go
$ wget https://dl.google.com/go/go1.12.5.linux-amd64.tar.gz -P $DEV_BASE/tmp
$ cd $DEV_BASE/tmp
$ tar xzvf go1.12.5.linux-amd64.tar.gz
$ mv go $DEV_BASE/go/go1.12.5
$ ln -s go1.12.5 default
```

Creamos el directorio `$DEV_BASE/code/go`y los subdirectorios `src`, `pkg` y `bin`, que nos servirán como directorios de trabajo para nuestro código:

```
$ mkdir -p $DEV_BASE/code/go/src
$ mkdir -p $DEV_BASE/code/go/pkg
$ mkdir -p $DEV_BASE/code/go/bin
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Go config
export GOROOT=$DEV_BASE/go/default
export GOPATH=$DEV_BASE/code/go
export PATH=$GOROOT/bin:$PATH
```

## Node.js / npm

*https://github.com/nodejs/help/wiki/Installation*

```
$ mkdir $DEV_BASE/nodejs
$ wget https://nodejs.org/dist/v10.15.3/node-v10.15.3-linux-x64.tar.xz -P $DEV_BASE/tmp
$ tar xf node-v10.15.3-linux-x64.tar.xz
$ mv node-v10.15.3-linux-x64 $DEV_BASE/nodejs/node-v10.15.3
$ ln -s $DEV_BASE/nodejs/node-v10.15.3 $DEV_BASE/nodejs/default
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# NodeJS config
export NODEJS_HOME=$DEV_BASE/nodejs/default/bin
export PATH=$NODEJS_HOME:$PATH
```

## Angular

*https://github.com/angular/angular-cli/wiki*

Teniendo Node.js y npm instalados, vamos a instalar Angular CLI *https://cli.angular.io/*:

```
$ npm install -g @angular/cli
```

Podemos probar la instalación creando un proyecto de prueba y lanzando el servidor:

```
$ cd $DEV_BASE/tmp
$ ng new my-project
$ cd my-project
$ ng serve
```

Accedemos a la url (http://localhost:4200/) para comprobar que la aplicación está levantada.

### Instalación de módulos en un proyecto

Podemos usar `npm` para instalar paquetes en un determinado proyecto.

#### Angular Material

*https://material.angular.io/*

Instalamos Angular Material, Angular CDK y Angular Animations *(https://material.angular.io/guide/getting-started)*:

```
$ npm install --save @angular/material @angular/cdk @angular/animations
```

#### PrimeNG

*https://www.primefaces.org/primeng/*

Instalamos PrimeNG y Prime Icons *(https://www.primefaces.org/primeng/#/setup)*:

```
$ npm install primeng --save
$ npm install primeicons --save
```

## Apache Maven

```
$ mkdir $DEV_BASE/apache-maven
$ wget http://apache.uvigo.es/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz -P $DEV_BASE/tmp
$ cd $DEV_BASE/tmp
$ tar xzvf apache-maven-3.6.1-bin.tar.gz
$ mv apache-maven-3.6.1 $DEV_BASE/apache-maven
$ ln -s $DEV_BASE/apache-maven/apache-maven-3.6.1 $DEV_BASE/apache-maven/default
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Maven config
export MAVEN_HOME=$DEV_BASE/apache-maven/default
export PATH=$MAVEN_HOME/bin:$PATH
```

## Apache Ant

```
$ mkdir $DEV_BASE/apache-ant
$ wget http://apache.uvigo.es//ant/binaries/apache-ant-1.9.14-bin.tar.gz -P $DEV_BASE/tmp
$ cd $DEV_BASE/tmp
$ tar xzvf apache-ant-1.9.14-bin.tar.gz
$ mv apache-ant-1.9.14 $DEV_BASE/apache-ant
$ ln -s $DEV_BASE/apache-ant/apache-ant-1.9.14 $DEV_BASE/apache-ant/default
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Ant config
export ANT_HOME=$DEV_BASE/apache-ant/default
export PATH=$ANT_HOME/bin:$PATH
```

## Docker

*(https://docs.docker.com/install/linux/docker-ce/debian/)*

```
# apt remove docker docker-engine docker.io containerd runc
# apt update
# apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common
# curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
# apt-key fingerprint 0EBFCD88
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
# apt update
# apt install docker-ce docker-ce-cli containerd.io
```

Para poder usar Docker como usuario no root, añadimos al usuario al grupo docker:

```
$ sudo usermod -aG docker your-user
```

### Docker compose

https://docs.docker.com/compose/install/#install-compose

Descargamos e instalamos la última versión (v1.24.0) con:

```
# curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Para finalizar, le damos permisos de ejecución:

```
# chmod a+x /usr/local/bin/docker-compose
```


TODO: kubectl
TODO: Gradle
TODO: httpd
TODO: Tomcat
TODO: MongoDB
TODO: Postgresql
TODO: Oracle
TODO: MySQL
TODO: Jenkins
TODO: Docker registry
TODO: Artifactory
