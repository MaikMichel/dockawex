#!/bin/bash

url_files=(    
  ${FILE_JRE}
  ${FILE_ORDS}
  ${FILE_TOMCAT}
  ${FILE_APEX}
  ${FILE_CLIENT}
  ${FILE_SQLPLUS}
  ${FILE_APEX_PATCH}
)

downloadFiles() {
  local url=${DOWNLOAD_URL}
  local i=1


  for file in "${url_files[@]}"; do
    if [ ! -f /files/${file} ]; then 
      echo "/files/${file} does not exists"
      echo "[Downloading '$file' (file $i/${#url_files[@]}) from '$url/$file']"
      curl -# --retry 6 -m 1800 --create-dirs -o /files/$file -L -C - $url/$file
    else
      echo "/files/${file} does exists"
    fi

    i=$((i + 1))
  done
  
}

downloadFiles

ls -la /files

# if now one file is missing, we have to quit...
if [ ! -f /files/${FILE_JRE} ] || [ ! -f /files/${FILE_ORDS} ] || [ ! -f /files/${FILE_TOMCAT} ] || [ ! -f /files/${FILE_APEX} ] || [ ! -f /files/${FILE_CLIENT} ] || [ ! -f /files/${FILE_SQLPLUS} ]; then  
  echo "not all requiered files found. aborting"
  exit 1
fi

echo "Extracting instantclient"
unzip -q /files/${FILE_CLIENT} -d /
unzip -q /files/${FILE_SQLPLUS} -d /
