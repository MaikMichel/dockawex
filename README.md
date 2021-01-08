# Introduction

[![APEX Community](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/78c5adbe/badges/apex-community-badge.svg)]() [![APEX Tool](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/b7e95341/badges/apex-tool-badge.svg)]() [![APEX 18.2](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/2fee47b7/badges/apex-18_2-badge.svg)]() [![APEX Built with Love](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/7919f913/badges/apex-love-badge.svg)]()

With DOCKAWEX you can easily create your local APEX development environment consisting of Oracle Database 18c XE, Tomcat with ORDS and an additional node proxy. Additionally you have the possibility to remotely build a container architecture for your APEX project via docker-machine and the included drivers. Here your containers will be additionally secured via Let's Encrypt and nginx and made known in the cloud.


---

## System Requirements

- [Docker](https://www.docker.com)
- [Docker-Compose](https://www.docker.com)
- [AWS-CLI](https://aws.amazon.com/de/cli/) (optional)

## Download Software

For licensing reasons, you must host or provide the software packages to be installed yourself.


File                                                 | What / Link
---------------------------------------------------- | -----------------------------------------------------------------------------------------------------------------------------------------------------------
oracle-database-xe-18c-1.0-1.x86_64.rpm              | https://www.oracle.com/database/technologies/xe-downloads.html <br/>- Oracle DB 18c XE
jre-8u271-linux-x64.tar.gz                           | https://javadl.oracle.com/webapps/download/AutoDL?BundleId=242050_3d5a2bb8f8d4428bbe94aed7ec7ae784 <br/>- JRE which will run tomcat
apache-tomcat-8.5.59.tar.gz                          | http://mirror.23media.de/apache/tomcat/tomcat-8/v8.5.54/bin/apache-tomcat-8.5.59.tar.gz <br/>- Applicationserver, here will ORDS installed to
ords-20.3.0.301.1819.zip                             | https://www.oracle.com/database/technologies/appdev/rest.html <br/>- Oracle REST Data Services, will provide access to APEX
apex_20.2.zip                                        | https://www.oracle.com/tools/downloads/apex-downloads.html <br/>- APEX complete
instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip | http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html <br/>- Clientssoftware, to connect to oracle db
instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip   | http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html <br/>- SQLPlus<br/>- install APEX and run your scripts and deployments
p32006852_2020_Generic.zip                           | https://support.oracle.com/epmos/faces/PatchDetail?patchId=32006852 <br/>- Patchsetbundle to be installed alongside
                                                       

When you are building against **local** machine, you can pack all files into the directories called "_binaries"
```shell
infrastructure/docker/appsrv/_binaries
  apache-tomcat-8.5.59.tar.gz
  apex_20.2.zip
  instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip
  instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip
  jre-8u271-linux-x64.tar.gz
  ords-20.3.0.301.1819.zip
  p32006852_2020_Generic.zip
infrastructure/docker/oradb/_binaries
  oracle-database-xe-18c-1.0-1.x86_64.rpm
```
From here all files are copied into the respective image.  
Otherwise when building against remote machine, load the files into a directory of your choice (your website, S3, ...) from where they must be accessible via http(s). The URL for downloading these files has to be placed in your corresponding env-file.

## Local installation as development environment

The configurations of the individual machines are stored in the "machines/*" directory. Here, each directory represents a machine. The local machine is also stored here. It is located in the folder **default**. Each directory must contain a .env - file. Here you have to store some configurations. Feel free to copy the **_template**-folder, rename it and change vars as you need.

### 1. Modify environment vars inside machines/default/.env

```bash
# Binaries to use
export DOWNLOAD_URL=https://your-url-pointing-to-binaries

export FILE_DB=oracle-database-xe-18c-1.0-1.x86_64.rpm
export FILE_ORDS=ords-20.3.0.301.1819.zip
export FILE_TOMCAT=apache-tomcat-8.5.59.tar.gz
export FILE_APEX=apex_20.2.zip
export FILE_SQLPLUS=instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip

export FILE_JRE=jre-8u271-linux-x64.tar.gz
# if you extract the tar.gz this is the name of the directory inside
export FILE_JRE_VERSION=jre1.8.0_271  
 
export FILE_CLIENT=instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip
# if you extract the zip this is the name of the directory inside
export FILE_INSTANT_CLIENT_VERION=instantclient_19_6

# Timezone 
export TIME_ZONE=Europe/Berlin

# DB Passes
export DB_SID=xepdb1
export DB_PASSWORD=SecurePwd123
export TOM_PASSWORD=SecurePwd123
export ORDS_PASSWORD=SecurePwd123

# APEX properties
export APEX_USER=APEX_200200
export INTERNAL_MAIL=your.admin-mail@somewhere.com

# mail properties
export SMTP_HOST_ADDRESS=your.smtp-server.com
export SMTP_FROM=default-from-name
export SMTP_USERNAME=your-user
export SMTP_PASSWORD=and-pwd


####### Following stuff is only used when using remote configuration #######

# Point to and certificate 
export VIRTUAL_HOST=your.domain.com
export LETSENCRYPT_HOST=your.domain.com
export LETSENCRYPT_EMAIL=your.admin-mail@somewhere.com
# during test set to true because letsencrypt does not allow
# more than 5 calls per week
export LETSENCRYPT_TEST=false
# with that info we say hello to our dyndns-service

# APEX Appliction-Number to redirect on /
APP_NUM=100

# curl to
export DDNS_USER=your-ddns-user
export DDNS_PASSWORD=with-password-when-using-curl
export DDNS_URL=ddns.server.org

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
      ././local.sh command
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

| Typ              | Link |
|------------------|-------------------------------------------|
| APEX             | http://localhost:8080/ords                |
| DOOZLE           | http://localhost:9000                     |
| SQLDeveloper Web | http://localhost:8080/ords/sql-developer  |
| DB               | \<user>/\<pass>@localhost:1521/xepdb1     |



---

## Remote installation for the public

> docker-machine must be available on your client machine

On Windows 10:
```bash
$: if [[ ! -d "$HOME/bin" ]]; then mkdir -p "$HOME/bin"; fi && \
curl -L https://github.com/docker/machine/releases/download/v0.16.2/docker-machine-Windows-x86_64.exe > "$HOME/bin/docker-machine.exe" && \
chmod +x "$HOME/bin/docker-machine.exe"
```

Otherwise visit: https://github.com/docker/machine/releases/ for further instructions

---
When using AWS:

### Prerequisite [Create an AWS account and authorized user](_docs/prepare_aws.md)

### 1a. Modify AWS Settings

After you have installed and configured aws-cli and created an IAM user, you can now write your account parameters to an environment file **account-alias.env**.

1. place a file inside provider subdirectory (provider/my-aws-settings.env).
2. Set content to:

```bash
ACCESS_KEY_ID=<Your AWS Access Key ID>
SECRET_ACCESS_KEY=<Your AWS Secret Access Key>
VPC_ID=<Your AWS VPC ID>
```

When using DigitalOcean:

### Prerequite [Create an DigitalOcean Account and API Token]

### 1b.  Modify DO Settings

After you have configured an API-TOKEN in DO, you can now write your account parameters to an environment file **account-alias.env**.

1. place a file inside provider subdirectory (provider/my-do-settings.env).
2. Set the content to:

```bash
DRIVER_TYPE=OCEAN
export OCEAN_TOKEN=<your token>
export OCEAN_TAG=<your tag>
```


### 2. Create a copy of the directory "_template" an name it descriptive e.g.  your-machine

### 3. Modify environment vars inside machines/your-machine/.env

This is like the local section mention above. Just set your vars.

### 4. Call script **remote.sh** to manage your remote setup

1. change your working directory to the machines path: ```cd dockawex```
2. create machine: ```dockawex$> ./remote.sh full switch provider/your-do-settings.env my-droplet create```
3. build images: ```dockawex$> ./remote.sh full switch provider/your-do-settings.env my-droplet build```
4. build images: ```dockawex$> ./remote.sh full switch provider/your-do-settings.env my-droplet start```

> More parameters will be displayed if you omit the parameters. ```dockawex$> ./remote.sh```

```bash
  $ ./remote.sh 
  Usage ./remote.sh full|dev switch|no_switch machine-prov-file machine-name command

  full|dev
    > full: all containers (nginx, letsencrypt)
    > dev:  only db, appsrv and node-proxy

  switch|no_switch
    > switch: use docker-machine to switch to machine
    > no_switch: without remote-compose (nginx, letsencrypt)

  machine-prov-file
    > file used by docker-machine driver (aws, digitalocean)
      if not exists then no machine will be created

  machine-name
    > name of ec2-instance / droplet

  command
    > create > creates only ec2-instance
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
    > remove > remove machine
    > exec   > calls compose only and attach params
```

ready...
Check https://your-sub.domain.de/ords APEX is waiting ...
> Check https://your-sub.domain.de YOUR APP is waiting (see $APP_NUM)

---
# FAQ

1. What is the password to internal?
> It is the same as for the user sys, except with an exclamation mark at the end!

2. How can I use machines on PC2 when the are created on PC1?
> see: https://www.npmjs.com/package/machine-share

3. How can I test access to external resources via APIproxy?
```sql
    select apex_web_service.make_rest_request(
             p_url => 'http://nodeprx:3000/https/postman-echo.com/time/start?timestamp=2020-04-29&unit=month',
             p_http_method => 'GET')
      from dual
```

4. What are the login-credentials when using SQL Developer Web?
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

