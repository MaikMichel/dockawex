#!/bin/bash


# All Params are required
usage() {
	echo
  echo
  echo -e "${BYELLOW}Please call script by using params...!${NC}"
	echo -e "    $0 machinename app-env-file command [options...]"
  echo -e "-------------------------------------------------------------------------------------------------"
  echo -e
  echo -e "  ${YELLOW}machinename${NC}"
  echo -e "    name of machine / ec2-instance (folder)"
  echo -e
  echo -e "  ${YELLOW}app-env-file${NC}"
  echo -e "    file with application specific vars"
  echo -e
  echo -e "  ${YELLOW}command${NC}"
  echo -e "    ${GREEN}base${NC}        - executes the base-config to run the app "
  echo -e "                    followed by version of init version"
  echo -e "                    e.g. ${GREEN}$0 ${EC2_NAME} ${APPLICATION} base 1.0.0${NC}"
  echo -e
  echo -e "    ${GREEN}init${NC}        - installs app in specific version"
  echo -e "                    followed by version to install initially"
  echo -e "                    e.g. ${GREEN}$0 ${EC2_NAME} ${APPLICATION} init 1.0.0${NC}"
  echo -e
  echo -e "    ${GREEN}patch${NC}       - installs a new release in specific version"
  echo -e "                    followed by version to install on top"
  echo -e "                    e.g. ${GREEN}$0 ${EC2_NAME} ${APPLICATION} patch 1.1.0${NC}"
  echo -e
  echo -e "    ${GREEN}imp_app_sql${NC} - restores data from given file"
  echo -e "                    followd by file to import"
  echo -e "                    e.g. ${GREEN}$0 ${EC2_NAME} ${APPLICATION} imp_app_sql path/to/back_up.sql${NC}"
  echo -e
  echo -e "    ${GREEN}imp_app_dmp${NC} - restores data from given file"
  echo -e "                    followd by file to import"
  echo -e "                    e.g. ${GREEN}$0 ${EC2_NAME} ${APPLICATION} imp_app_dmp path/to/back_up.dmp${NC}"
  echo -e
  echo -e "    ${GREEN}bash${NC}        - bash into container"
  echo -e
  echo -e "    ${GREEN}sql${NC}         - starts sqlcl"
  echo -e "                    all other params are send to sclcl"
  echo -e
  echo -e "    ${GREEN}nginx${NC}       - writes configuration for nginx"
  echo -e
  echo -e "-------------------------------------------------------------------------------------------------"
}

#RED='\033[0;31m'
#NC='\033[0m' # No Color

# Reset
NC="\033[0m"       # Text Reset

# Regular Colors
BLACK="\033[0;30m"        # Black
RED="\033[0;31m"          # Red
GREEN="\033[0;32m"        # Green
YELLOW="\033[0;33m"       # Yellow
BLUE="\033[0;34m"         # Blue
PURPLE="\033[0;35m"       # Purple
CYAN="\033[0;36m"         # Cyan
WHITE="\033[0;37m"        # White
BYELLOW="\033[1;33m"       # Yellow

echo_red(){
    echo -e "${RED}${1}${NC}"
}


EC2_NAME=${1}
APPLICATION=${2}
COMMAND=${3}
OPTIONS=${@:4}

echo "EC2_NAME=${EC2_NAME}"
echo "APPLICATION=${APPLICATION}"
echo "COMMAND=${COMMAND}"

###################################################################################################

# check required params
if [ -z "$EC2_NAME" ]; then
  echo_red "ERROR: machinename is missing!"
  usage
  exit 1
fi

if [ ! -d "$EC2_NAME" ]; then
  echo_red "ERROR: machinename does not exists as folder!"
  ls -ld */
  usage
  exit 1
fi

if [ -z "$APPLICATION" ]; then
  echo_red "ERROR: application is missing!"
  usage
  exit 1
fi

if [ ! -f ${EC2_NAME}/${APPLICATION} ]; then
    echo_red "Application-File: ${EC2_NAME}/${APPLICATION} not found!"
    exit 1
fi

if [ -z "$COMMAND" ]; then
  echo_red "ERROR: command is missing!"
  usage
  exit 1
fi

if [[ "$WORD" =~ ^(init|patch|base)$ ]]; then
  if [ -z "$OPTIONS" ]; then
    echo_red "ERROR: version of release is missing!"
    usage
    exit 1
  fi
fi

if [[ "$WORD" =~ ^(imp_app_dmp|imp_app_sql)$ ]]; then
  if [ -z "$OPTIONS" ]; then
    echo_red "ERROR: backup-file is missing!"
    usage
    exit 1
  fi
fi

###################################################################################################

# switch to machine
UNAME=$(uname);

if [[ "$UNAME" = "Darwin" && "${EC2_NAME}" = "default" ]]
then
  echo "No switching $UNAME on ${EC2_NAME} detected"
else
  echo "Switching to machine: ${EC2_NAME}"
  docker-machine env ${EC2_NAME}
  eval $(docker-machine env ${EC2_NAME})
fi

# env vars
source ${EC2_NAME}/.env
source ${EC2_NAME}/${APPLICATION}


# target imagename
# IMAGE:NAME=${EC2_NAME}_$(echo "${APPLICATION}" | cut -f 1 -d '.')
IMAGE_NAME="wilddogsmith/xdepl"

# docker command
DOCKER_CMD="docker run -it --rm --network ${EC2_NAME}_default --volumes-from ${EC2_NAME}_appsrv_1 --env-file=${EC2_NAME}/${APPLICATION} -e DB_TNS=${EC2_NAME}_oradb_1:1521/${DB_SID} -e SQLCL=sql --volumes-from nginx-proxy ${IMAGE_NAME}"

# if not default/local use nginx volumes
NGINX_EXISTS="TRUE"
if [ ! "$(docker ps -q -f name=nginx-proxy)" ]; then
  DOCKER_CMD="docker run -it --rm --network ${EC2_NAME}_default --volumes-from ${EC2_NAME}_appsrv_1 --env-file=${EC2_NAME}/${APPLICATION} -e DB_TNS=${EC2_NAME}_oradb_1:1521/${DB_SID} -e SQLCL=sql ${IMAGE_NAME}"
  NGINX_EXISTS="FALSE"
fi
# echo "DOCKER_CMD: ${DOCKER_CMD}"



base_install() {
  echo ${DOCKER_CMD} base $OPTIONS

  ${DOCKER_CMD} base $OPTIONS
}

init_install() {
  echo ${DOCKER_CMD} init $OPTIONS

  ${DOCKER_CMD} init $OPTIONS
}

patch_install() {
  echo ${DOCKER_CMD} patch $OPTIONS

  ${DOCKER_CMD} patch $OPTIONS
}

nginx_config() {
  if [ "$NGINX_EXISTS" != "TRUE" ]; then
    echo "nginx runs only on remote"
  else
    ${DOCKER_CMD} nginx

    echo "restarting nginx-proxy"

    docker kill --signal=HUP nginx-proxy
    docker start nginx-proxy
  fi
}

imp_app_sql(){
  local backup_file=$OPTIONS
  echo "uploading backup to container"
  # copy given file to appserver-container
  docker cp ${backup_file} ${EC2_NAME}_appsrv_1:/u01/apps/${PROJECT}/last_backup.sql

  # start image and run file from that volume
  ${DOCKER_CMD} imp_app_sql
}

imp_app_dmp(){
  local backup_file=$OPTIONS

  echo "uploading backup to db-container"
  # copy given file to dbserver-container
  docker cp ${backup_file} ${EC2_NAME}_oradb_1:/tmp/${backup_file##*/}

  ${DOCKER_CMD} imp_app_dmp ${backup_file##*/}
}

exec_bash() {
  ${DOCKER_CMD} bash $OPTIONS
}

case $COMMAND in
	'build')
		build_image
		;;
  'base')
		base_install
		;;
  'init')
		init_install
		;;
  'patch')
		patch_install
		;;
  'imp_app_sql')
		imp_app_sql
		;;
  'imp_app_dmp')
		imp_app_dmp
		;;
  'bash')
		exec_bash
		;;
  'nginx')
		nginx_config
		;;
	*)
		echo_red "unknown command"
    exit 1
		;;
esac