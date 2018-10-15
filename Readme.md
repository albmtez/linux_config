# Dev environment

Vamos a hacer la instalación y configuración de un entorno de desarrollo multi-lenguaje y multi-herramienta.

La instalación se basa en una serie de binarios, código fuente e instaladores que se han descargado de las páginas de referencia de cada herramienta o aplicación y que se han agrupado en una estructura de directorios (que llamaremos `$SRC`). Si quieres seguir esta guía, puedes recuperar estos archivos de las distintas páginas de descarga.

La instalación se realiza sobre un **Ubuntu 18.04**.

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

## Git

*(fuente: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)*

Podemos instalar git desde el gestor de paquetes apt con `sudo apt install git-all`. Sin embargo, haremos la instalación desde el código fuente para tener control sobre la versión que utilizamos.

Para compilar el código fuente de git necesitamos instalar unos paquetes:

```
sudo apt install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev \
                 libssl-dev asciidoc xmlto docbook2x install-info
```

Recuperamos el código fuente y descomprimimos:

```
cp $SRC/git/git-2.19.1.tar.gz $DEV_BASE/tmp
tar xzvf git-2.19.1.tar.gz
```

Ya podemos compilar e instalar. Haremos la instalación en $HOME/dev/git/git-2-19.1.

```
$ cd git-2.19.1
$ make configure
$ ./configure --prefix=$HOME/dev/git/git-2.19.1
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

