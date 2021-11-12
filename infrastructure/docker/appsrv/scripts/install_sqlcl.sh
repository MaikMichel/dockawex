#!/bin/bash

exec >> >(tee -ai /docker_log.txt)
exec 2>&1

cd /files

echo "unpacking sqlcl"
unzip -q sqlcl.zip


echo "moving sqlcl to /usr/bin"
mv sqlcl /usr/local/

export PATH="/usr/local/sqlcl/bin:${PATH}"