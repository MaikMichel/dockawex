#!/bin/bash
target_dir=/u01/apps
FILE_APEX_PATCH=apex_patch.zip
export SQLPLUS=sqlplus
SQLPLUS_ARGS="sys/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} as sysdba"

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

if [ -z ${URL_APEX_PATCH} ]; then
  echo "no URL to download"
  exit 1
fi

# removeFile
rm -rf /files/${FILE_APEX_PATCH}

# downloadFiles
echo "downloading patch"
curl -# --retry 6 -m 1800 --create-dirs -o /files/${FILE_APEX_PATCH} ${URL_APEX_PATCH}

if [ ! -f /files/${FILE_APEX_PATCH} ]; then
    # just proof
  ls -la /files/apex_patch*

  echo "no patchset found"
  exit 1
fi

 # when patch file found then unzip
if [ -f /files/$FILE_APEX_PATCH ]
then
  echo "Extracting PatchSet $FILE_APEX_PATCH"
  rm -rf ${target_dir}/apexpatch
  mkdir ${target_dir}/apexpatch
  unzip -q /files/$FILE_APEX_PATCH -d ${target_dir}/apexpatch/

  cd ${target_dir}/apexpatch/*
  echo "Installing Patch $FILE_APEX_PATCH"
  $SQLPLUS -S $SQLPLUS_ARGS <<!
  @catpatch
!

  echo "Copy files from patch $FILE_APEX_PATCH"
  cp -rf ${target_dir}/apexpatch/*/images/* /tomcat/webapps/i

else
  echo "No PatchSet $FILE_APEX_PATCH found"
  exit 1
fi


echo "Done, installing patch $FILE_APEX_PATCH"
