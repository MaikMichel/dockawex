#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

echo "unpacking tomcat"
tar xzf /files/tomcat.tgz -C /tmp

TOMCAT_VERSION=9.0.54
echo "moving tomcat from /tmp/apache-tomcat-${TOMCAT_VERSION}  to /tomcat"
mv /tmp/apache-tomcat-${TOMCAT_VERSION} /tomcat

echo "clearing up tomcat"
rm /files/tomcat.tgz


rm -rf /tomcat/webapps/docs
rm -rf /tomcat/webapps/examples
rm -rf /tomcat/webapps/host-manager
rm -rf /tomcat/webapps/manager
rm -rf /tomcat/webapps/ROOT

sed -i -e 's/password="secret"/password="'$TOM_PASSWORD'"/g' /scripts/tomcat-users.xml
mv /scripts/tomcat-users.xml /tomcat/conf
mv /scripts/tomcat-server.xml /tomcat/conf/server.xml
mv /scripts/tomcat-web.xml /tomcat/conf/web.xml

# ErrorPages taken from https://github.com/HttpErrorPages/HttpErrorPages
mkdir /tomcat/webapps/ROOT
mv /scripts/HTTP400.html /tomcat/webapps/ROOT/HTTP400.html
mv /scripts/HTTP401.html /tomcat/webapps/ROOT/HTTP401.html
mv /scripts/HTTP403.html /tomcat/webapps/ROOT/HTTP403.html
mv /scripts/HTTP404.html /tomcat/webapps/ROOT/HTTP404.html
mv /scripts/HTTP500.html /tomcat/webapps/ROOT/HTTP500.html
mv /scripts/HTTP501.html /tomcat/webapps/ROOT/HTTP501.html
mv /scripts/HTTP502.html /tomcat/webapps/ROOT/HTTP502.html
mv /scripts/HTTP503.html /tomcat/webapps/ROOT/HTTP503.html
mv /scripts/HTTP520.html /tomcat/webapps/ROOT/HTTP520.html
mv /scripts/HTTP521.html /tomcat/webapps/ROOT/HTTP521.html
mv /scripts/HTTP533.html /tomcat/webapps/ROOT/HTTP533.html


mv /scripts/tomcat9 /etc/init.d/tomcat
chmod 755 /etc/init.d/tomcat


echo "tomcat installed"

# /etc/init.d/tomcat start
# /etc/init.d/tomcat stop
# /etc/init.d/tomcat restart
