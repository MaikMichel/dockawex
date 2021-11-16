#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

echo "--------------------------------------------------"
echo "Download FILES...................................."
set -x && ./scripts/download_files.sh

echo "--------------------------------------------------"
echo "Installing TOMCAT................................."
./scripts/install_tomcat.sh
