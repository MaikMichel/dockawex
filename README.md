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


File                                           | What / Link
---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
oracle-database-xe-18c-1.0-1.x86_64.rpm        | https://www.oracle.com/database/technologies/xe-downloads.html <br/>- Oracle DB 18c XE
jre-8u171-linux-x64.tar.gz                     | http://download.oracle.com/otn/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz <br/>- JRE which will run tomcat
apache-tomcat-8.5.31.tar.gz                    | http://mirror.23media.de/apache/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz <br/>- Applicationserver, here will ORDS and JasperReportIntegration installed to
ords-19.2.0.199.1647.zip                       | https://www.oracle.com/database/technologies/appdev/rest.html <br/>- Oracle REST Data Services, will provide access to APEX
JasperReportsIntegration-2.4.0.0.zip           | http://www.opal-consulting.de/downloads/free_tools/JasperReportsIntegration/2.4.0/JasperReportsIntegration-2.4.0.0.zip <br/>- free tool to run your jasper-files
apex_19.2.zip                                  | https://www.oracle.com/tools/downloads/apex-v191-downloads.html <br/>- APEX complete
instantclient-basic-linux.x64-12.1.0.2.0.zip   | http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html <br/>- Clientssoftware, to connect to oracle db
instantclient-sqlplus-linux.x64-12.1.0.2.0.zip | http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html <br/>- SQLPlus<br/>- install APEX and run your scripts and deployments
sqlcl-19.2.1.206.1649.zip                      | https://www.oracle.com/tools/downloads/sqldev-v192-downloads.html <br/>- SQLCL

When you are building against **local** machine, you can pack all files into the directories called "_binaries"
```shell
deployment/docker/apex_deployment/_binaries
  instantclient-basic-linux.x64-12.1.0.2.0.zip
  instantclient-sqlplus-linux.x64-12.1.0.2.0.zip
infrastructure/docker/appsrv/_binaries
  apache-tomcat-8.5.31.tar.gz
  apex_19.2.zip
  instantclient-basic-linux.x64-12.1.0.2.0.zip
  instantclient-sqlplus-linux.x64-12.1.0.2.0.zip
  JasperReportsIntegration-2.4.0.0.zip
  jre-8u171-linux-x64.tar.gz
  ords-19.2.0.199.1647.zip
infrastructure/docker/oradb/_binaries
  oracle-database-xe-18c-1.0-1.x86_64.rpm
```
From here all files are copied into the respective image.  
Otherwise when building against remote machine, load the files into a directory of your choice (your website, S3, ...) from where they must be accessible via http(s).

## Local installation as development environment

The configurations of the individual machines are stored in the "machines/*" directory. Here, each directory represents a machine. The local machine is also stored here. It is located in the folder **default**. Each directory must contain a .env - file. Here you have to store some configurations. Feel free to copy the **_template**-folder, rename it and change vars as you need.


### 2. Call script **infra_local.sh** to manage your local setup

1. change your working directory to dockawex: ```cd dockawex```
2. build images: ```dockawex$> ./infra_local.sh build```
3. start container: ```dockawex$> ./infra_local.sh start```

> More parameters will be displayed if you omit the parameters. ```dockawex$> ./infra_local.sh```

ready...
At http://localhost:8080/ords (or 192.168.99.100/ords when using docker-toolbox) APEX is waiting for you

---

## Remote installation for the public

### Prerequisite [Create an AWS account and authorized user](_docs/prepare_aws.md)

### 1. Modify AWS Settings

After you have installed and configured aws-cli and created an IAM user, you can now write your account parameters to an environment file **account-alias.env**.

1. copy the file _template.env and name it descriptive e.g. your-aws-settings.env
2. Change following parameters:

```bash
ACCESS_KEY_ID=<Your AWS Access Key ID>
SECRET_ACCESS_KEY=<Your AWS Secret Access Key>
VPC_ID=<Your AWS VPC ID>
```

### 2. Create a copy of the directory "_template" an name it descriptive e.g.  your-machine

### 3. Customizing the Infrastructure Settings ```machines/your-machine/custom-compose.yml```
#TODO: Hier fehlt text


### 4. Call script **setup_remote.sh** to manage your remote setup

1. change your working directory to the machines path: ```cd dockawex/machines```
2. build images: ```dockawex/machines$> ./setup_remote.sh your-aws-settings your-machine-name build```
3. start container: ```dockawex/machines$> ./setup_remote.sh your-aws-settings your-machine-name start```

> More parameters will be displayed if you omit the parameters. ```awex/machines$> ./awex_remote.sh```

ready...
Check https://your-sub.domain.de/ords APEX is waiting ...

---

## Deploy an APEX-App
#TODO: Eigenen Container draus machen
If you want to use the `dockawex` deployment container, you can place one env file per application in the respective machine folder. Here `dockawex` expects two repositories. One for the application itself and the other one to install patches on top of the initaly installed application. Directory of the APP-repoy must have the following structure:
```bash
  apex
    fxxx                        -> Application folder with splitted structur underneath
      enable_build_options.sql  -> called by pre_install.sql and sets build options defined in app.env
      install.sql               -> called by pre_install.sql and generated by APEX exporter
      pre_install.sql           -> called by installation container
    rest
      install_ldc.sql           -> called by installation container
      restful_services.sql      -> calles by install_ldc, exported services by APEX
  db    
    build_all.sql               -> called by installation container, when installing
    drop_all.sql                -> called by installation container, when installing, NOT on upgrade option
  reports
    *.jasper                    -> compiled jasperfiles to deploy
```
I suggest to place all other DB-objects inside "db"-folder like:
```
..
  db
    constraints
      primary_keys
      foreign_keys
      unique_keys
      checks
    source
      functions
      procedure
      packages
    tables
    tables_ddl
    indexes
..

```
For example app.env (default)

### 1. Modify application parameters

```bash
#
# DOCKAWEX environment vars
#

# user data to access git repos, you could leave that out 
# if repo is public 
#MY_GIT_USER=
#MY_GIT_PASS=
MY_GIT_USER="<REPLACE_THIS>"
MY_GIT_PASS="<REPLACE_THIS>"

# APP:          URL to repo where to find the full application
# PATCHES:      URL to repo where to load PATCHES/RELEASES from
MY_GIT_URL_APP="<REPLACE_THIS>"
MY_GIT_URL_PATCHES="<REPLACE_THIS>"

# URL to get files from 
# Oracle Client and SQLPlus
DOWNLOAD_URL=<REPLACE_THIS>
FILE_CLIENT=instantclient-basic-linux.x64-12.1.0.2.0.zip
FILE_SQLPLUS=instantclient-sqlplus-linux.x64-12.1.0.2.0.zip

# user data to send mails with
# this is optional and will only applied when using smtp option in deployment container
SMTP_HOST_ADDRESS=<REPLACE_THIS>
SMTP_FROM=<REPLACE_THIS>
SMTP_USERNAME=<REPLACE_THIS>
SMTP_PASSWORD=<REPLACE_THIS>

# User to Add Workspace and grant some basic roles - see dockerfile of deployment container
SYS_USER=sys
SYS_PASS="<REPLACE_THIS>"

# APEX user inclusive version some grants and acls will assigned to
# for example: APEX_USER=APEX_180200
APEX_USER=<REPLACE_THIS>

# APP / schema user who will own and or call installation / Workspace
APP_USER=<REPLACE_THIS>
APP_PASS="<REPLACE_THIS>"

# name of APEX workspace to install app to
APP_WSPACE=<REPLACE_THIS>

# name on volumes to install/clone into from git
# /u01/apps/APP_WSPACE/APP_PATH/app
# /u01/apps/APP_WSPACE/APP_PATH/patches
APP_PATH=<REPLACE_THIS>


# target application number to install to
APP_NUM=<REPLACE_THIS>

# mails from system will send to this address (notifications)
APP_MAIL=<REPLACE_THIS>

# server proxied by nginx
# this is used to rewrite calls for location / to that app
APP_SERVER=<REPLACE_THIS>

# if you are using build-options or leave it out
APP_BUILD_OPTION_LIKE=<REPLACE_THIS>

# user data to be used by jasper_report_integration
REP_USER=<REPLACE_THIS>
REP_PASS="<REPLACE_THIS>"

```

### 2. Build deployment container based on APP-settings

1. build image: ```dockawex/machines$> ./deployment.sh your-machine-name build```
1. install your app: ```dockawex/machines$> ./deployment.sh your-machine-name install```

> More parameters will be displayed if you omit the parameters. ```dockawex/machines$> ./deployment.sh```

---
# FAQ

1. What is the password to internal?
> It is the same as for the user sys, except with an exclamation mark at the end!

2. How can I use machines on PC2 when the are created on PC1?
> see: https://www.npmjs.com/package/machine-share

3. How can I test access to external resources via APIproxy?
```sql
    select apex_web_service.make_rest_request(
             p_url => 'http://nodeprx:3000/https/postman-echo.com/time/start?timestamp=2016-10-10&unit=month',
             p_http_method => 'GET')
      from dual
```

---
# Credits
Dockerfiles are based on and with the influence of:
- https://github.com/araczkowski/docker-oracle-apex-ords
- https://github.com/jwilder/nginx-proxy

Some inspirations are coming from:
- https://github.com/Dani3lSun/docker-db-apex-dev

