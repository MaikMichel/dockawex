#!/bin/bash

downloadFiles() {
  local url=${DOWNLOAD_URL}

  local url_files=(    
    ${FILE_JRE}
    ${FILE_ORDS}
    ${FILE_TOMCAT}
    ${FILE_APEX}
    ${FILE_CLIENT}
    ${FILE_SQLPLUS}
  )

  mkdir /files
  cd /files

  local i=1
  for file in "${url_files[@]}"; do
    echo "[Downloading '$file' (file $i/${#url_files[@]}) from '$url/$file']"
    curl -# --retry 6 -m 1800 --create-dirs -o /files/$file -L -C - $url/$file

    i=$((i + 1))
  done
  
}

# download the all files if APEX is not there
echo "check if files exists..."
ls -l /files


# if one file is missing all will be downloaded
if [ ! -f /files/${FILE_JRE} ] || [ ! -f /files/${FILE_ORDS} ] || [ ! -f /files/${FILE_TOMCAT} ] || [ ! -f /files/${FILE_APEX} ] || [ ! -f /files/${FILE_CLIENT} ] || [ ! -f /files/${FILE_SQLPLUS} ]; then  
  downloadFiles  
fi

# if now one file is missing, we have to quit...
if [ ! -f /files/${FILE_JRE} ] || [ ! -f /files/${FILE_ORDS} ] || [ ! -f /files/${FILE_TOMCAT} ] || [ ! -f /files/${FILE_APEX} ] || [ ! -f /files/${FILE_CLIENT} ] || [ ! -f /files/${FILE_SQLPLUS} ]; then  
  exit 1
fi

echo "Extracting instantclient"
unzip -q /files/${FILE_CLIENT} -d /
unzip -q /files/${FILE_SQLPLUS} -d /
