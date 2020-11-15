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

  TARGET_FILE="/etc/nginx/vhost.d/dockawex_proxy.conf"
  echo "  writing $TARGET_FILE"

  echo "server_tokens off;" > $TARGET_FILE
  echo "client_max_body_size 100m;" >> $TARGET_FILE

else
  echo "nginx vhost.d path not found"
fi

if [ -d "/etc/nginx/conf.d" ]; then  
  TARGET_FILE="/etc/nginx/conf.d/dockawex_proxy.conf"
  echo "  writing $TARGET_FILE"

  echo "server_tokens off;" > $TARGET_FILE
  echo "client_max_body_size 100m;" >> $TARGET_FILE

else
  echo "nginx conf.d path not found"
fi