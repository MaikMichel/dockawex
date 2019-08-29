#!/bin/bash

echo "Extracting Jasper"
# Unipping to /tmp
unzip -o -q /files/$FILE_JASPER -d /tmp/

# Creating directory-structur
echo "Creating directory structure"
mkdir /u01/jasper/
cp -R /tmp/conf /tmp/logs /tmp/reports /u01/jasper/

echo "SettingUp ConfigurationDir"
cd /tmp/bin
chmod +x *.sh; sync

echo "Calling setConfigDir.sh"
./setConfigDir.sh ../webapp/JasperReportsIntegration.war /u01/jasper

echo "changing user data"
# Changing Password
sed -i -E 's:my_oracle_user_pwd:'$REP_PASSWORD':g' /u01/jasper/conf/application.properties
sed -i -E 's:my_oracle_user:'$REP_USER':g' /u01/jasper/conf/application.properties
sed -i -E 's:127.0.0.1:'$REP_HOST':g' /u01/jasper/conf/application.properties
sed -i -E 's:infoPageIsEnabled=true:'infoPageIsEnabled=$REP_ENABLE_INFOPAGE':g' /u01/jasper/conf/application.properties

# Encrypting Password
echo "encrypting pwds"
./encryptPasswords.sh /u01/jasper/conf/application.properties

echo "copy to webapps"
cp /tmp/webapp/JasperReportsIntegration.war /tomcat/webapps

echo "jasper ready"
