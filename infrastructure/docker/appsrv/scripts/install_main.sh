#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

echo "--------------------------------------------------"
echo "Download FILES...................................."
./scripts/download_files.sh
#
#
echo "--------------------------------------------------"
echo "Installing JAVA..................................."
./scripts/install_java.sh
#
#
echo "--------------------------------------------------"
echo "Installing TOMCAT................................."
./scripts/install_tomcat.sh
#
#
echo "--------------------------------------------------"
echo "Clean............................................."
echo "Removing temp files"
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
echo "--------------------------------------------------"
echo "DONE.............................................."
