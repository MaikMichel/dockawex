#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

# downloadFiles
echo "downloading files"
curl -# --retry 6 -m 1800 --create-dirs -o /files/tomcat.tgz ${URL_TOMCAT}
curl -# --retry 6 -m 1800 --create-dirs -o /files/ords.zip ${URL_ORDS}
curl -# --retry 6 -m 1800 --create-dirs -o /files/apex.zip ${URL_APEX}

# if now one file is missing, we have to quit... || [ ! -f /files/sqlcl.zip ]
if [ ! -f /files/tomcat.tgz ] || [ ! -f /files/ords.zip ] || [ ! -f /files/apex.zip ]; then
    # just proof
  ls -la /files

  echo "not all requiered files found. aborting"
  exit 1
fi
