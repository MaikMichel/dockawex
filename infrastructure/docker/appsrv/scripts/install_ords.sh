#!/bin/bash
target_dir=/u01/apps

echo "Extracting Ords"
mkdir ${target_dir}/ords
unzip -q -o /files/$FILE_ORDS -d ${target_dir}/ords/

sed -i -E 's:DB_PASSWORD:'$DB_PASSWORD':g' /scripts/ords_params.properties
sed -i -E 's:ORDS_PASSWORD:'$ORDS_PASSWORD':g' /scripts/ords_params.properties
sed -i -E 's:DB_HOST:'$DB_HOST':g' /scripts/ords_params.properties
sed -i -E 's:DB_SID:'$DB_SID':g' /scripts/ords_params.properties

cp -rf /scripts/ords_params.properties ${target_dir}/ords/params

cd ${target_dir}/ords
java -jar ords.war configdir ${target_dir}
java -jar ords.war install
java -jar ords.war set-property security.verifySSL false

cp -rf ${target_dir}/ords/ords.war /tomcat/webapps/
cp -rf ${target_dir}/apex/images /tomcat/webapps/i
