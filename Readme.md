# Dev environment

Vamos a hacer la instalación y configuración de un entorno de desarrollo multi-lenguaje y multi-herramienta.

La instalación se basa en una serie de binarios, código fuente e instaladores que se han descargado de las páginas de referencia de cada herramienta o aplicación y que se han agrupado en una estructura de directorios (que llamaremos `$SRC`). Si quieres seguir esta guía, puedes recuperar estos archivos de las distintas páginas de descarga.

La instalación se realiza sobre un **Ubuntu 18.10**.

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
