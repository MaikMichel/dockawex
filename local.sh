#!/bin/bash

# All Params are required
if [ $# -lt 1 ]; then
	echo "Please call script by using all params in this order!"
	echo "    $0 command"
  echo "-----------------------------------------------------"
  echo
  echo "  command "
  echo "    > build  > builds only images"
  echo "    > start  > start images / containers "
  echo "    > run    > builds and start images / containers "
  echo "    > logs   > shows logs by executing logs -f "
  echo "    > list   > list services"
  echo "    > config > view compose files"
  echo "    > print  > print compose call"
  echo "    > stop   > stops services"
  echo "    > clear  > removes all container and images, prunes allocated space"
  echo
  echo "-----------------------------------------------------"
	echo "Canceled !!!"
  echo
	exit 1
fi

COMMAND=$1
OPTION=$2

# call remote
./remote.sh dev environments/local.env ${COMMAND} ${OPTION}