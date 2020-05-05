#!/bin/bash

echo "Checking nginx..."
if [ -d "/etc/nginx/vhost.d" ]; then
  TARGET_FILE="/etc/nginx/vhost.d/default_location"
  echo "  writing $TARGET_FILE"
  echo "proxy_set_header Origin \"\";" > $TARGET_FILE 

  TARGET_FILE="/etc/nginx/vhost.d/${VIRTUAL_HOST}"
  echo "  writing $TARGET_FILE"
  echo "location = / {" > $TARGET_FILE
  echo "  rewrite ^ /ords/f?p=${APP_NUM};" >> $TARGET_FILE
  echo "}" >> $TARGET_FILE
  echo "gzip on;" >> $TARGET_FILE

  TARGET_FILE="/etc/nginx/vhost.d/${VIRTUAL_HOST}_location"
  echo "  writing $TARGET_FILE"
  echo "proxy_set_header Origin \"\";" > $TARGET_FILE

  


else
  echo "Nginx path not found"
fi