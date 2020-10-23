#!/bin/bash

cd /files

echo "unpacking tomcat: tar -xzf $FILE_TOMCAT"
tar -xzf $FILE_TOMCAT

FILE_TOMCAT_WITHOUT_EXT=${FILE_TOMCAT/.tar.gz/}
echo "move /files/$FILE_TOMCAT_WITHOUT_EXT /tomcat"
mv /files/$FILE_TOMCAT_WITHOUT_EXT /tomcat



sed -i -e 's/password="secret"/password="'$TOM_PASSWORD'"/g' /scripts/tomcat-users.xml
mv /scripts/tomcat-users.xml /tomcat/conf
mv /scripts/tomcat-server.xml /tomcat/conf/server.xml
mv /scripts/tomcat-web.xml /tomcat/conf/web.xml
cp /scripts/tomcat-error.jsp /tomcat/conf/error.jsp
mv /scripts/tomcat-error.jsp /tomcat/webapps/error.jsp

rm -rf /tomcat/webapps/docs
rm -rf /tomcat/webapps/examples
rm -rf /tomcat/webapps/host-manager
rm -rf /tomcat/webapps/manager
rm -rf /tomcat/webapps/ROOT


mv /scripts/tomcat8 /etc/init.d/tomcat
chmod 755 /etc/init.d/tomcat
update-rc.d tomcat defaults  80 01

echo "tomcat installed"