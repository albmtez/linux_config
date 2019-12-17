# Dev environment

Vamos a hacer la instalación y configuración de un entorno de desarrollo multi-lenguaje y multi-herramienta.

La instalación se basa en una serie de binarios, código fuente e instaladores que se han descargado de las páginas de referencia de cada herramienta o aplicación y que se han agrupado en una estructura de directorios (que llamaremos `$SRC`). Si quieres seguir esta guía, puedes recuperar estos archivos de las distintas páginas de descarga.

La instalación se realiza sobre un **Ubuntu 19.04**.

## Preparación del directorio base

Vamos a hacer la instalación del entorno de desarrollo de forma que todas las aplicaciones y herramientas que sea posible queden contenidas dentro de un mismo directorio dentro del `$HOME` del usuario.

Por tanto, vamos a crear el directorio base:

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
$ sudo apt install build-essential git-all cvs subversion mercurial maven ant etckeeper git-cvs git-svn subversion-tools openjdk-8-jdk openjdk-11-jdk
```

## Git

*(fuente: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)*

Podemos instalar git desde el gestor de paquetes apt con `sudo apt install git-all`. Sin embargo, haremos la instalación desde el código fuente para tener control sobre la versión que utilizamos.

Para compilar el código fuente de git necesitamos instalar unos paquetes:

```
$ sudo apt install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev \
                 libssl-dev asciidoc xmlto docbook2x install-info
```

Recuperamos el código fuente y descomprimimos:

```
$ cp $SRC/git/git-2.19.1.tar.gz $DEV_BASE/tmp
$ tar xzvf git-2.19.1.tar.gz
```

Ya podemos compilar e instalar. Haremos la instalación en $HOME/dev/git/git-2-19.1.

```
$ mkdir $DEVBASE/git
$ cd git-2.19.1
$ make configure
$ ./configure --prefix=$DEV_BASE/git/git-2.19.1
$ make all
$ make install
```

Finalmente, establecemos esta versión como la que usaremos por defecto en el entorno de desarrollo:

```
$ ln -s $DEV_BASE/git/git-2.19.1 $DEV_BASE/git/default
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
$ cp $SRC/python/Python-3.7.1.tgz $DEV_BASE/tmp
$ cd $DEV_BASE/tmp
$ cd tar xzvf Python-3.7.1.tgz
$ cd Python-3.7.1
$ ./configure --prefix=$DEV_BASE/python/python-3.7.1
$ make
$ make install
```

Creamos el enlace `default` a la versión que queremos usar por defecto *(https://bugs.python.org/issue30090)*:

```
$ ln -s $DEV_BASE/python/python-3.7.1 $DEV_BASE/python/default
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
$ python3 -m venv env-python-3.7.1
```

## Golang

*Al hacer los untar, utilizaremos la opción **--no-same-permissions** para que tome el umask del usuario*

Recuperamos los binarios de las distintas versiones de Go de `$SRC/golang`. Los descomprimimos en `$DEV_BASE/go` y creamos un enlace **default** al directorio de la versión que queremos usar por defecto, con lo que tendríamos:

```
user@host:~/dev/go$ ls -l
total 32
lrwxrwxrwx  1 user group    8 Oct 24 15:40 default -> go1.11.1
drwx------ 11 user group 4096 Feb 16  2018 go1.10.0
drwx------ 11 user group 4096 Mar 29  2018 go1.10.1
drwx------ 11 user group 4096 Apr 30 22:34 go1.10.2
drwx------ 11 user group 4096 Jun  7 02:12 go1.10.3
drwx------ 10 user group 4096 Aug 24 21:35 go1.10.4
drwx------ 10 user group 4096 Aug 24 22:41 go1.11.0
drwx------ 10 user group 4096 Oct  1 23:02 go1.11.1
drwx------ 11 user group 4096 Jun  6 21:49 go1.9.7
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

Recuperamos los binarios de las distintas versiones de `$SRC/nodejs`. Los descomprimimos en `$DEV_BASE/nodejs` y creamos un enlace **default** al directorio de la versión que queremos usar por defecto, con lo que tendríamos:

```
user@host:~/dev/nodejs$ ll
total 4
lrwxrwxrwx 1 user group   12 Nov  7 08:33 default -> node-v11.1.0
drwx------ 6 user group 4096 Nov  2 10:27 node-v11.1.0
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

## Oracle JDK

Recuperamos los binarios de las distintas versiones de `$SRC/java`. Los descomprimimos en `$DEV_BASE/jdk` y creamos un enlace **default** al directorio de la versión que queremos usar por defecto, con lo que tendríamos:

```
user@host:~/dev/jdk$ ll
total 52
lrwxrwxrwx 1 user group   10 Nov  7 15:52 default -> jdk-11.0.1
drwx------ 8 user group 4096 Nov  7 15:49 jdk-10
drwx------ 8 user group 4096 Nov  7 15:50 jdk-10.0.1
drwx------ 8 user group 4096 Nov  7 15:50 jdk-10.0.2
drwx------ 8 user group 4096 Nov  7 15:57 jdk-11
drwx------ 8 user group 4096 Nov  7 15:51 jdk-11.0.1
drwx------ 8 user group 4096 Apr 11  2015 jdk1.7.0_80
drwx------ 8 user group 4096 Mar 29  2018 jdk1.8.0_171
drwx------ 8 user group 4096 Mar 29  2018 jdk1.8.0_172
drwx------ 7 user group 4096 Oct  6 14:55 jdk1.8.0_191
drwx------ 7 user group 4096 Oct  6 15:58 jdk1.8.0_192
drwx------ 8 user group 4096 Nov  7 15:48 jdk-9
drwx------ 8 user group 4096 Nov  7 15:48 jdk-9.0.1
drwx------ 8 user group 4096 Nov  7 15:49 jdk-9.0.4
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Java config
export JAVA_HOME=$DEV_BASE/jdk/default
export PATH=$JAVA_HOME/bin:$PATH
```

## Glassfish

*https://javaee.github.io/*
*https://javaee.github.io/glassfish/*

Recuperamos los zip con los binarios de `$SRC/glassfish` correspondientes a las distintas versiones y los descomprimimos en `DEV_BASE/glassfish`:

```
user@host:~/dev$ ll glassfish/
total 4
drwxr-xr-x 6 user group 4096 Sep  8  2017 glassfish5
```

## Apache Maven

Recuperamos los binarios de las distintas versiones de `$SRC/apache-maven`. Los descomprimimos en `$DEV_BASE/apache-maven` y creamos un enlace **default** al directorio de la versión que queremos usar por defecto, con lo que tendríamos:

```
user@host:~/dev/apache-maven$ ll
total 8
drwx------ 6 user group 4096 Nov  7 16:56 apache-maven-3.5.4
drwx------ 6 user group 4096 Nov  7 16:54 apache-maven-3.6.0
lrwxrwxrwx 1 user group   18 Nov  7 16:54 default -> apache-maven-3.6.0
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Maven config
export MAVEN_HOME=$DEV_BASE/apache-maven/default
export PATH=$MAVEN_HOME/bin:$PATH
```

## Apache Ant

Recuperamos los binarios de las distintas versiones de `$SRC/apache-ant`. Los descomprimimos en `$DEV_BASE/apache-ant` y creamos un enlace **default** al directorio de la versión que queremos usar por defecto, con lo que tendríamos:

```
user@host:~/dev/apache-ant$ ll
total 8
drwx------ 6 user group 4096 Jul 10 06:49 apache-ant-1.10.5
drwx------ 6 user group 4096 Jul 10 06:18 apache-ant-1.9.13
lrwxrwxrwx 1 user group   17 Nov  7 17:06 default -> apache-ant-1.10.5
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# Ant config
export ANT_HOME=$DEV_BASE/apache-ant/default
export PATH=$ANT_HOME/bin:$PATH
```

## Apache Tomcat

Recuperamos los binarios de las distintas versiones de `$SRC/apache-tomcat`. Los descomprimimos en `$DEV_BASE/apache-tomcat`:

```
user@host:~/dev/apache-tomcat$ ll
total 16
drwx------ 9 user group 4096 Nov  7 17:13 apache-tomcat-7.0.91
drwx------ 9 user group 4096 Nov  7 17:13 apache-tomcat-8.0.53
drwx------ 9 user group 4096 Nov  7 17:13 apache-tomcat-8.5.34
drwx------ 9 user group 4096 Nov  7 17:13 apache-tomcat-9.0.12
```

## SQL Developer

Recuperamos los binarios de las distintas versiones de `$SRC/sqldeveloper`. Los descomprimimos en `$DEV_BASE/sqldeveloper`.

## Eclipse

Recuperamos los binarios de las distintas versiones de `$SRC/eclipse`. Los descomprimimos en `$DEV_BASE/eclipse`.

Creamos el directorio para los workspaces:

```
$ mkdir $DEV_BASE/eclipse_workspaces
```

### Instalación plugins Eclipse

- JD-Eclipse: Seguir las instrucciones de http://jd.benow.ca/.
- Subclipse: Instalar desde el Marketplace.
  - Instalar el paquete libsvn-java `$ sudo apt-get install libsvn-java` para tener compatibilidad JavaHL.
  - Buscar dónde está instalado: `$ sudo find / -name libsvnjavahl-1.so`
  - Editar el archivo eclipse.ini para añadir la línea siguiente tras la opción “-vmargs”:
```
-vmargs
-Djava.library.path=/usr/lib/x86_64-linux-gnu/jni
```
- PyDev
- Shell Script (DLTK)
- Checkstyle (eclipse-cs)
- SonarLint
- SQL Development Tools
- Eclipse Docker Tooling
- TestNG
- Spring Tools
- Angular IDE

## MongoDB

Recuperamos los binarios de las distintas versiones de `$SRC/mongodb`. Los descomprimimos en `$DEV_BASE/mongodb` y creamos un enlace **default** al directorio de la versión que queremos usar por defecto, con lo que tendríamos:

```
user@host:~/dev/mongodb$ ll
total 4
lrwxrwxrwx 1 user group   26 nov  8 12:26 default -> mongodb-linux-x86_64-4.0.4
drwx------ 3 user group 4096 nov  8 12:26 mongodb-linux-x86_64-4.0.4
```

Creamos un directorio para las bases de datos:

```
$ mkdir $DEV_BASE/mongodb_databases
```

### Configuración

Añadimos la siguiente configuración a `$DEV_BASE/bash_profile`:

```
# MongoDB config
export MONGODB_HOME=$DEV_BASE/mongodb/default
export PATH=$MONGODB_HOME/bin:$PATH
```

### Base de datos de prueba

Vamos a crear una base de datos de prueba. Para ello, creamos la estructura de directorios para almacenar sus archivos y los logs:

```
$ mkdir -p $DEV_BASE/mongodb_databases/test/db
```

Arrancamos MongoDB con:

```
$ mongod --directoryperdb --dbpath $DEV_BASE/mongodb_databases/test/db --logpath $DEV_BASE/mongodb_databases/test/log --logappend
```

Y nos podemos conectar con:

```
$ mongo
```

## Java Decompiler GUI

Seguimos las indicaciones de http://jd.benow.ca/. Básicamente, descargamos el paquete .deb y lo instalamos.

## Visual Studio Code

Descargamos el paquete deb desde la web (https://code.visualstudio.com/) y lo instalamos. Esto añade el repositorio para descargar las actualizaciones.

### Plugins

Instalamos los siguientes plugins desde la terminal:

* Settings Sync: ```$ code --install-extension shan.code-settings-sync```
* Go: ```$ code --install-extension ms-vscode.go```
* Docker: ```$ code --install-extension ms-azuretools.vscode-docker```
* Cloud Code: ```$ code --install-extension googlecloudtools.cloudcode```
* Bash Debug: Requiere la instalación del paquete bashdb ($ sudo apt-get install bashdb) ```$ code --install-extension rogalmic.bash-debug```
* SVN: ```$ code --install-extension johnstoncode.svn-scm```
* Vagrant: ```$ code --install-extension bbenoist.vagrant```
* vscode-icons: ```$ code --install-extension vscode-icons-team.vscode-icons```
* GitLens: ```$ code --install-extension eamodio.gitlens```
* Project Manager: ```$ code --install-extension alefragnani.project-manager```
* Paste JSON as Code: ```$ code --install-extension quicktype.quicktype```
* Bookmarks: ```$ code --install-extension alefragnani.bookmarks```
* Live Server: ```$ code --install-extension ritwickdey.liveserver```
* Markdown Preview Enhanced: ```$ code --install-extension shd101wyy.markdown-preview-enhanced```
* Code Runner: ```$ code --install-extension formulahendry.code-runner```
* vscode-faker: ```$ code --install-extension deerawan.vscode-faker```
* Python: ```$ code --install-extension ms-python.python```
* Debugger for Chrome: ```$ code --install-extension msjsdiag.debugger-for-chrome```
* C/C++: ```$ code --install-extension ms-vscode.cpptools```
* Kubernetes: ```$ code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools```
* GitHub Pull Requests: ```$ code --install-extension GitHub.vscode-pull-request-github```
* C#: ```$ code --install-extension ms-vscode.csharp```
* XML Tools: ```$ code --install-extension dotjoshjohnson.xml```
* TODO Hightlights: ```$ code --install-extension wayou.vscode-todo-highlight```
* Todo Tree: ```$ code --install-extension gruntfuggly.todo-tree```
* Java: Podemos instalar el paquete Java Extension Pack o los siguientes, uno a uno. ```$ code --install-extension vscjava.vscode-java-pack```
  * Language Support for Java by Red Hat: ```$ code --install-extension redhat.java```
  * Maven for Java: ```$ code --install-extension vscjava.vscode-maven```
  * Debugger for Java: ```$ code --install-extension vscjava.vscode-java-debug```
  * Java Test Runner: ```$ code --install-extension vscjava.vscode-java-test```
  * Spring Boot Tools: ```$ code --install-extension Pivotal.vscode-spring-boot```
  * Spring Initializr Java Support: ```$ code --install-extension vscjava.vscode-spring-initializr```
  * Tomcat for Java: ```$ code --install-extension adashen.vscode-tomcat```
  * Checkstyle for Java: ```$ code --install-extension shengchen.vscode-checkstyle```
* Angular
  * Angular Extension Pack: ```$ code --install-extension loiane.angular-extension-pack```
* Ansible: ```$ code --install-extension vscoss.vscode-ansible```

#### Instalación automática

Se pueden instalar los plugins listados anteriormente ejecutando el script `vscode_plugins_install.sh`.

## GitEye

Descargamos el archiv zip de la web (https://www.collab.net/products/giteye).

	# umask 0027     -> para mantener los permisos de grupo
	# mkdir GitEye-2.0.0
	# cp GitEye-2.0.0-linux.x86_64.zip GitEye-2.0.0
	# cd GitEye-2.0.0
	# unzip GitEye-2.0.0-linux.x86_64.zip
	# rm GitEye-2.0.0-linux.x86_64.zip
	# cd ..
	# mkdir /opt/development/GitEye
	# cp -R GitEye-2.0.0 /opt/development/GitEye
	# ln -s /opt/development/GitEye/GitEye-2.0.0-linux.x86_64.zip /opt/development/GitEye/default

## Gitg

Instalamos el cliente git desde el repositorio:

```
$ sudo apt install gitg
```

## SmartGit

Descargar el paquete .deb de la web e instalar (https://www.syntevo.com/smartgit/).

## GitKraken

https://www.gitkraken.com/

Instalamos con snap:

```
$ sudo snap install gitkraken
```

## KVM

```
$ sudo apt install qemu-kvm virtinst virt-top virt-manager seabios qemu-utils ovmf
```

Añadimos el usuario al grupo libvirt:

```
$ sudo usermod -a -G libvirt <usuario>
```

Para permitir la visualización en virt-manager del uso de memoria, I/O y red hay que ir a Edición-Preferencias para habilitar las estadísticas. Después, ya podemos añadirlas en el menú Vista.

## Virtualbox

Seguir las instrucciones de la web (https://www.virtualbox.org/) para instalarlo (descargar el paquete .deb e instalarlo).
Añadimos al usuario al grupo vboxusers:

```
$ sudo usermod -a -G vboxusers <usuario>
```

## Vagrant

Instalamos el paquete descargado de la web: https://www.vagrantup.com

### Vagrant plugins

Instalamos el paquete de compatibilidad con libvirt:

```$ vagrant plugin install vagrant-libvirt```

Si falla la instalación porque no encuentra la librería libvirt, ejecutar el comando siguiente:

```
$ sudo apt install libvirt-dev
```

Conversión de boxes para su compatibilidad con distintos providers.

```
$ vagrant plugin install vagrant-mutate
```

Para convertir un box hacemos:

```
$ vagrant box mutate <box_name> <dest_provider>
```

Instalamos el plugin vagrant-disksize (https://github.com/sprotheroe/vagrant-disksize), que permite cambiar el tamaño del disco principal de la vm:

```
$ vagrant plugin install vagrant-disksize
```

Instalamos el plugin vagrant-vbguest, que nos permite instalar VBox Guest Additions:

```
$ vagrant plugin install vagrant-vbguest
```

Para instalarlo, con una máquina ya arrancada con vagrant up hacemos:

```
$ vagrant vbguest
```

## Puppet

```
$ sudo apt-get install puppet
```

## Ansible

Instalamos el repositorio PPA ansible/ansible e instalamos el paquete apt desde él:

```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```

## Chef

https://www.chef.sh/

Descargamos los paquetes .deb desde la web y los instalamos:

* Chef workstation
* Chef client

## Docker / Kubernetes

### Docker

https://docs.docker.com/install/linux/docker-ce/ubuntu/

Desinstalamos posibles antiguas versiones de Docker Engine:

```
$ sudo apt-get remove docker docker-engine docker.io
```

Instalamos Docker CE (El repositorio que se añade es el de Bionic - Ubuntu 18.04):

```
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
$ sudo apt update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Para poder usar Docker como usuario no root, añadimos al usuario al grupo docker:

```
$ sudo usermod -aG docker your-user
```

### Docker compose

https://docs.docker.com/compose/install/#install-compose

Descargamos e instalamos la última versión (v1.24.1) con:

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

Para finalizar, le damos permisos de ejecución:

```
$ sudo chmod a+x /usr/local/bin/docker-compose
```

### Docker machine

https://docs.docker.com/machine/install-machine/

Instalamos la última versión (v0.16.0) ejecutando:

```
$ base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo install /tmp/docker-machine /usr/local/bin/docker-machine
```

### kubectl / Minnikube

https://kubernetes.io/es/docs/tasks/tools/install-kubectl/
https://kubernetes.io/docs/tasks/tools/install-minikube/

Instalamos kubectl:

```
$ sudo apt update && sudo apt-get install -y apt-transport-https
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
$ echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
$ sudo apt update
$ sudo apt install -y kubectl
```

Ahora instalamos la última versión de minikube):

```
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo cp minikube /usr/local/bin/ && rm minikube && sudo chmod a+r+x /usr/local/bin/minikube
```

### Helm

https://github.com/helm/helm/releases/latest

Descargamos el tgz con el binario de la url anterior, lo descomprimimos en el directorio **$DEV_HOME/helm** y creamos el enlace simbólico **default**:

```
user@host:~/dev/helm$ ll
total 4
lrwxrwxrwx 1 usger group   11 nov 28 23:18 default -> helm-2.11.0
drwx------ 2 usger group 4096 sep 25 20:17 helm-2.11.0
```

#### Configuración

Añadimos al archivo `$DEV_BASE/bash_profile` la configuración siguiente:

```
# Helm config
export HELM_HOME=$DEV_BASE/helm/default
export PATH=$HELM_HOME:$PATH
```
