#!/bin/bash


target_dir=/u01/apps
URL_APEX_PATCH=${1}

FILE_APEX_PATCH=apex_patch.zip
export SQLPLUS=sqlplus
SQLPLUS_ARGS="sys/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} as sysdba"
SQLPLUS_ARGS2="sys/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID2} as sysdba"


# exec >> >(tee -ai /docker_log.txt)
# exec 2>&1

if [ -z ${URL_APEX_PATCH} ]; then
  echo "No Patch URL to download"
  exit 1
fi

# is URL valid?
regex='(https)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
if [[ ! ${URL_APEX_PATCH} =~ $regex ]]
then
    echo "Invalid Patch URL: ${URL_APEX_PATCH}"
fi

# is URL reachable
if curl --output /dev/null --silent --head --fail "${URL_APEX_PATCH}"; then
  echo "Patch URL exists: ${URL_APEX_PATCH}"
else
  echo "Patch URL does not exist: ${URL_APEX_PATCH}"
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

  line=$(head -n 1 README.txt)
  echo "Installing Patch ${line} on ${DB_SID}"
  $SQLPLUS -S $SQLPLUS_ARGS <<!
  @catpatch
!

  if [[ ${USE_SECOND_PDB,,} == "true" ]]; then
    echo "Installing Patch ${line} on ${DB_SID2}"
    $SQLPLUS -S $SQLPLUS_ARGS <<!
  @catpatch
!

  fi

  echo "Copy files from patch $FILE_APEX_PATCH"
  cp -rf ${target_dir}/apexpatch/*/images/* /tomcat/webapps/i

else
  echo "No PatchSet $FILE_APEX_PATCH found"
  exit 1
fi


echo "Done, installing patch: ${line}"
