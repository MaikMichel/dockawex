#!/bin/bash

downloadFiles() {
	local url=${DOWNLOAD_URL}

	local url_files=(
		${FILE_JASPER}
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

if [ ! -f /files/${FILE_APEX} ]; then
  downloadFiles
fi

echo "Extracting instantclient_12_1"
unzip -q /files/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /
unzip -q /files/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /
