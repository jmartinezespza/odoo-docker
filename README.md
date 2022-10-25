# Jhonny Odoo Docker image Ubuntu 22.04

```
Se puede usar el siguient repositorio:
jmespza/odoo-ubuntu:16.0   <- Latest v15 image

```
Anotaciones Open Source Docker image

* Odoo Community Edition, installed from source in `/opt/odoo`
* Supports custom addons in `/opt/odoo/custom_addons`
* Includes an `odoo-config` script for modifying the odoo config file in derrived images
* Includes Git and SSH clients for development
* Includes Visual Studio Code folder mount points
* Allows easy passing of additional odoo args, or running other commands like the bash shell

# Set-up

## Prerequisites

* Docker instalado
* Access to a PostgreSQL 9+ Database Server

## Configuring

This image requires the following environment variables.

* `DB_HOST` - Postgres Database server address. Set to `host.docker.internal` to use your local machine. Se puede usar 172.17.0.1
* `DB_PORT` - Postgres Database server port. Normally 5432
* `DB_USER` - Odoo database user. This must NOT be your PostgreSQL super user (`postgres`)
* `DB_PASSWORD` - Odoo database user password.

We recommend creating an `odoo.env` file to store your database configuration.

## Overriding Odoo Configuration Settings

This image ships with a default `odoo.conf` in `/etc/odoo`. You can either replace this file with
your own version, or use our `odoo-config` tool to update individual settings.

To override individual settings, create and build you own `Dockerfile` with content such as the below:

```Dockerfile
FROM jmespza/odoo-ubuntu:16.0

RUN odoo-config addons_path+=,/opt/odoo/custom_addons/my_lib/addons \
                list_db=True
```
(you can either append to existing settings using `+=`, or overwrite them using `=`)

Para desarrollo se recomienda crear un nuevo Dockerfile agregando los cambios necesarios como la reconfiguración del addons_path o la instalacion de dependencias python.

# Creating a database and running the image

The following example walks you through creating a new Odoo database using this image:

1. In a new folder, create an `odoo.env` file, as above. 
Se colocará la configuración de Odoo a Postgres.

2. Create a blank PostgreSQL database owned by your Odoo database user, e.g.

```sql
CREATE DATABASE odoo15 OWNER odoo ENCODING UTF8;
```
Se puede usar modo comando o PgAdmin para crear el usuario y base de datos. 

3. Run this image with the following command in the Terminal to initialise your new
   Odoo database

```bash
docker run --rm -it \
    -v ruta-odoo-data:/opt/odoo/data \
    -p 8069:8069 \
    --env-file=odoo.env \
    jmespza/odoo-ubuntu:13.0 \
    odoo -d odoo14 -i base --without-demo=all --load-language=es_PE
```

(where `odoo14` is the new database name)
(ruta-odoo-data es la ruta de la carpeta en la PC local)

4. Now that your database has been initialised, you can restart it with a
   simpler command. You might find it useful to save the below into a
   `start-odoo.sh` script, which you can run instead of typing it out!

```bash
docker run --rm -it \
    -v ruta-odoo-data:/opt/odoo/data \
    -p 8069:8069 \
    --env-file=odoo.env \
    jmespza/odoo-ubuntu:13.0 odoo -d odoo14
```

se puede compartir con -v las rutas /opt/odoo/.vscode, /opt/odoo/custom_addons, /home/odoo

Your Odoo system should now be accessible at http://localhost:8069 o http://172.17.0.1:8069/. You can log
in using the default user: admin, password: admin

# Development

## Running

The below script should be run in Git Bash on windows, or in the Terminal application on Mac and Linux

```bash
# Run the junari/odoo docker image with default settings
./run.sh
```

You can also pass any `odoo-bin` args via `run.sh`, e.g.:

```bash
# Initialise a new database (with demo data disabled)
./run.sh odoo -d db_name -i base --without-demo=all --load-language=en_GB

# Run with a specific database
./run.sh odoo -d db_name

# Access the odoo shell for a specific database
./run.sh odoo-shell -d db_name

# Access bash inside the container
./run.sh bash
```

## Re-building the image

```bash
# Re-build the images (with the latest ubuntu)
./build.sh
```
Se usó el repositorio de junari/odoo docker.