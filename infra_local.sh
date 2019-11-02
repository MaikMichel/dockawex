#!/bin/bash

# All Params are required
if [ $# -lt 1 ]; then
	echo "Please call script by using all params in this order!"
	echo "    ./$0 command"
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
# default is machine-name for local
EC2_NAME="default"
SWITCH="switch_dm"

COMMAND=$1
OPTION=$2

case $(uname | tr '[:upper:]' '[:lower:]') in
linux*)
  SWITCH="no_switch"
;;
darwin*)
  SWITCH="no_switch"
;;
mingw64_nt-10*)
  SWITCH="no_switch"
;;
*)
  echo "executing defaults "
;;
esac

# call remote
./infra_remote.sh dev ${SWITCH} doesntmatter ${EC2_NAME} ${COMMAND} ${OPTION}