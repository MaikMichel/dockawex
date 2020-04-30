#!/bin/bash

downloadFiles () {
	# splitted DB Files
	local url_files=( 
		${FILE_DB}
	)

	# loop through array
	local i=1
	for part in "${url_files[@]}"; do     
		echo "[Downloading '$part' (part $i/${#url_files[@]}) from '$DOWNLOAD_URL/$part']"
		curl -# --retry 6 -m 1800 -o ${INSTALL_DIR}/$part -L -C - $DOWNLOAD_URL/$part	
		i=$((i + 1))
	done
}

# download the Oracle installer if not exists
if [ ! -f ${INSTALL_DIR}/${FILE_DB} ]; then
  downloadFiles
fi

# if it still not exists 
if [ ! -f ${INSTALL_DIR}/${FILE_DB} ]; then
  exit 1
fi