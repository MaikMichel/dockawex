# Introduction

[![APEX Community](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/78c5adbe/badges/apex-community-badge.svg)]() [![APEX Tool](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/b7e95341/badges/apex-tool-badge.svg)]() [![APEX Built with Love](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/7919f913/badges/apex-love-badge.svg)]()
[![Works with ORDS 22.1^](https://img.shields.io/badge/Works%20with-ORDS%2022.1%5E-orange)]()


With DOCKAWEX you can easily create your local APEX development environment consisting of Oracle Database 21c XE and Tomcat with ORDS. Your containers will be additionally secured via Let's Encrypt and nginx if you prefer when running on a virtual instance (ec2 or oci or droplet and so on).


---

## System Requirements

- [Docker](https://www.docker.com)
- [Docker-Compose](https://www.docker.com)


## Download Software

All tools will be downloaded during build. But you can change the Links in your environment file inside folder ```environments```. At the time of writing these lines the following packages are meant by that:

```bash
  export URL_ORDS=https://download.oracle.com/otn_software/java/ords/ords-22.1.1.133.1148.zip
  export URL_TOMCAT=https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.64/bin/apache-tomcat-9.0.64.tar.gz
  export URL_APEX=https://download.oracle.com/otn_software/apex/apex_22.1.zip
```

### APEX Patchset
If you want to install the current patchset of Oracle APEX you have to download it by your own https://support.oracle.com/epmos/faces/PatchDetail?patchId=32598392 and place it into a reachable URL:
```bash
export URL_APEX_PATCH=https://somewhere-out-there-where-you-can-place-some-file-temporaly.somewhere
```
> **ATTENTION**: You have to upload the patchset in binary mode to your remote server. Otherwise unzip will not be able to extract the file

### Install Patchset afterwards
When you want to install the patchset after the main installation or if there is a new patchset available you can install by executing the following lines:

```shell
  # attach to running appsrv instance
  docker exec -it local_appsrv_1 bash

  # export the URL to download patchset from
  export URL_APEX_PATCH=https://somewhere-out-there-where-you-can-place-some-file-temporaly.somewhere

  # run install script
  /scripts/patch_apex.sh

```

## Local installation as development environment

The configurations of the individual environments are stored in the "environments/" directory. Here, each *.env file represents an environment. Here you have to store some configurations. Feel free to copy the file `environments/_template/template.env` to environments/*.env. Or call script `remote.sh` with following parameters:

```bash
  ./remote.sh dev environments/my_new_environment.env new
```
This will copy the templatefile to that place. Here you have to take care of the parameters your propably want to change.


### 1. Modify environment vars inside environment file

```bash
# URLs to get Installables
export URL_ORDS=https://download.oracle.com/otn_software/java/ords/ords-22.1.1.133.1148.zip
export URL_TOMCAT=https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.64/bin/apache-tomcat-9.0.64.tar.gz
export URL_APEX=https://download.oracle.com/otn_software/apex/apex_22.1.zip

# File for generic patch version, must be download from oracle support
# and uploaded to a reachable url (ObjectStorage, S3, ...)
export URL_APEX_PATCH=

# if you want do not want to use a CDN you should comment that out
# ex. https://static.oracle.com/cdn/apex/22.1.0/
export APEX_IMAGE_PREFIX=

# Timezone
export TIME_ZONE=Europe/Berlin

# DB Passes (internal=DB_PASSWORD+!)
export DB_PASSWORD=
export TOM_PASSWORD=
export ORDS_PASSWORD=

# APEX properties
export INTERNAL_MAIL=

# mail properties
export SMTP_HOST_ADDRESS=
export SMTP_FROM=
export SMTP_USERNAME=
export SMTP_PASSWORD=


####### Following stuff is only used when using remote configuration #######

# Point to and certificate
export VIRTUAL_HOST=
export LETSENCRYPT_HOST=
export LETSENCRYPT_EMAIL=
# during test set to true because letsencrypt does not allow
# more than 5 calls per week
export LETSENCRYPT_TEST=false
# with that info we say hello to our dyndns-service

# APEX Appliction-Number to redirect on /
export APP_NUM=100

# curl to
export DDNS_USER=
export DDNS_PASSWORD=
export DDNS_URL=


```

### 2. Call script **local.sh** to manage your local setup

1. change your working directory to dockawex: ```cd dockawex```
2. build images: ```dockawex$> ./local.sh build```
3. start container: ```dockawex$> ./local.sh start```


> ready...
At http://localhost:8080/ords APEX is waiting for you

More parameters will be displayed if you omit the parameters.
```bash
  $ ./local.sh

  Please call script by using all params in this order!
    ./local.sh command
  -----------------------------------------------------

    command
      > build  > builds only images
      > start  > start images / containers
      > run    > builds and start images / containers
      > logs   > shows logs by executing logs -f
      > list   > list services
      > config > view compose files
      > print  > print compose call
      > stop   > stops services
      > clear  > removes all container and images, prunes allocated space
```

> If you have filled the email and smtp vars you will receive a message.
```sql
apex_mail.send(p_from => '${SMTP_FROM}'
              ,p_to   => '${INTERNAL_MAIL}'
              ,p_subj => 'DOCKAWEX successfully installed'
              ,p_body => 'Test Hey ho, that works');
```

| Typ              | Link                                      |
|------------------|-------------------------------------------|
| APEX             | http://localhost:8080/ords                |
| SQLDeveloper Web | http://localhost:8080/ords/sql-developer  |
| DB               | \<user>/\<pass>@localhost:1521/xepdb1     |



---

## Remote installation for the public

### Prerequisite

- create an compute instance on your cloud provider of choice. (OCI, AWS, DO, Azure, ...)
- install git and docker inclusive docker-compose on that machine or use a template for that
- configure firewall setting, so that this virtual machine is reachable by SSH, HTTP and HTTPS
- login to your instance by using ssh or cloud shell

### 1. Clone this repo

```bash
$ git clone https://github.com/MaikMichel/dockawex.git
```

### 2. Change your working directory create an environment with the properties you prefer

```bash
$ cd dockawex
# create env file
dockawex$> ./remote.sh full environments/my_env.env new

# edit env file
dockawex$> vi environments/my_env.env
```

### 3. Build images

```bash
# build docker images
dockawex$> ./remote.sh full environments/my_env.env build
```

### 4. Start images
```bash
# start images
dockawex$> ./remote.sh full environments/my_env.env start

# view logs of installtions
dockawex$> ./remote.sh full environments/my_env.env logs

```

On first start APEX will be installed and let's encrypt acme-challenge will be executed.

> More parameters will be displayed if you omit the parameters. ```dockawex$> ./remote.sh```

```bash
  dockawex$ ./remote.sh

  Usage remote.sh full|dev environment-file command

  full|dev
    > full: all containers (nginx, letsencrypt)
    > dev:  only db, appsrv and node-proxy

  environment
    > path to environment file ex: environments/demo.env

  command
    > build  > builds only images
    > start  > start images / containers
    > run    > creates, builds and start images / containers
    > logs   > shows logs by executing logs -f
    > renew  > forces letsencrypt to renew certificate
    > list   > list services
    > config > view compose files
    > print  > print compose call
    > stop   > stops services
    > clear  > clears services
    > exec   > calls compose only and attach params
    > new    > generates new environment file base on environment parameter
```

Check https://your-sub.domain.de/ords APEX is waiting ..
> Check https://your-sub.domain.de YOUR APP is waiting (see $APP_NUM)

---
# FAQ

1. What is the password to internal?
> It is the same as for the user sys, except with an exclamation mark at the end!

2. What are the login-credentials when using SQL Developer Web?
> you have to REST enable the database-schema
``` sql
  begin
    ords.enable_schema(p_enabled => TRUE,
                       p_schema => 'HR',
                       p_url_mapping_type => 'BASE_PATH',
                       p_url_mapping_pattern => 'hr',
                       p_auto_rest_auth => FALSE);
    commit;
  end;
  ```
  After that you can publish RESTful Service, REST Enable object and login SQL Developer Web. You can switch that off by editing infrastructure/docker/appsrv/scripts/ords_params.properties.


---
# Credits
Dockerfiles are based on and with the influence of:
- https://github.com/araczkowski/docker-oracle-apex-ords
- https://github.com/jwilder/nginx-proxy

Some inspirations are coming from:
- https://github.com/Dani3lSun/docker-db-apex-dev
