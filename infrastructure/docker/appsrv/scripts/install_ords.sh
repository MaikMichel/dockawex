#!/bin/bash
target_dir="/u01/apps"
FILE_APEX_PATCH=apex_patch.zip


echo "Extracting Ords"

mkdir -p ${ORDS_HOME}
cd ${ORDS_HOME}

unzip -oq /files/ords.zip
mkdir -p ${ORDS_CONF}/logs


export ORDS_CONFIG=${ORDS_CONF}
${ORDS_HOME}/bin/ords --config ${ORDS_CONF} install \
      --log-folder ${ORDS_CONF}/${DB_SID}/logs \
      --admin-user SYS \
      --db-hostname ${DB_HOST} \
      --db-port ${DB_PORT} \
      --db-servicename ${DB_SID} \
      --feature-db-api true \
      --feature-rest-enabled-sql true \
      --feature-sdw true \
      --gateway-mode proxied \
      --gateway-user APEX_PUBLIC_USER \
      --proxy-user \
      --password-stdin <<EOF
${DB_PASSWORD}
${ORDS_PASSWORD}
EOF

if [[ ${USE_SECOND_PDB,,} == "true" ]]; then
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONF} install \
        --log-folder ${ORDS_CONF}/${DB_SID2}/logs \
        --db-pool ${SECOND_POOL_NAME,,} \
        --admin-user SYS \
        --db-hostname ${DB_HOST} \
        --db-port ${DB_PORT} \
        --db-servicename ${DB_SID2} \
        --feature-db-api true \
        --feature-rest-enabled-sql true \
        --feature-sdw true \
        --gateway-mode proxied \
        --gateway-user APEX_PUBLIC_USER \
        --proxy-user \
        --password-stdin <<EOF
  ${DB_PASSWORD}
  ${ORDS_PASSWORD}
EOF

fi

  cp ords.war /tomcat/webapps/
  cp -rf ${target_dir}/apex/images /tomcat/webapps/i


# when patch included, it has been unzipped, now install it too
if [ -f /files/$FILE_APEX_PATCH ]
then
  echo "Copy files from patch $FILE_APEX_PATCH"
  cp -rf ${target_dir}/apexpatch/*/images/* /tomcat/webapps/i
else
  echo "No Patchfile $FILE_APEX_PATCH found"
fi