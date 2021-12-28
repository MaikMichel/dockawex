#!/bin/bash

# All Params are required
if [ $# -lt 3 ]; then
  echo
  echo "Usage $0 full|dev environment-file command"
  echo
  echo "  full|dev "
  echo "    > full: all containers (nginx, lets'encrypt)"
  echo "    > dev:  only db, appsrv and node-proxy"
  echo
  echo "  environment "
  echo "    > path to environment file ex: environments/demo.env "
  echo
  echo "  command "
  echo "    > build  > builds only images"
  echo "    > start  > start images / containers "
  echo "    > run    > creates, builds and start images / containers "
  echo "    > logs   > shows logs by executing logs -f "
  echo "    > renew  > forces letsencrypt to renew certificate"
  echo "    > list   > list services"
  echo "    > config > view compose files"
  echo "    > print  > print compose call"
  echo "    > stop   > stops services"
  echo "    > clear  > clears services"
  echo "    > exec   > calls compose only and attach params"
  echo "    > new    > generates new environment file base on environment parameter"
  echo
  echo
  exit 1
fi

STACK=$1
ENV_FILE=$2
COMMAND=$3
OPTION=$4


CONTAINER_PREFIX=${ENV_FILE##*/}
CONTAINER_PREFIX=${CONTAINER_PREFIX%.*}
export CONTAINER_PREFIX=${CONTAINER_PREFIX}

# path
INFRA_PATH="infrastructure"

if [ "${STACK}" == "full" ]
then
  COMPOSE_COMMAND="docker-compose -p ${CONTAINER_PREFIX} -f ${INFRA_PATH}/docker/docker-compose.yml -f ${INFRA_PATH}/docker/docker-compose-remote.yml -f ${INFRA_PATH}/docker/custom-compose.yml"
else
  COMPOSE_COMMAND="docker-compose -p ${CONTAINER_PREFIX} -f ${INFRA_PATH}/docker/docker-compose.yml -f ${INFRA_PATH}/docker/custom-compose.yml"
fi

if [ ! -f "${ENV_FILE}" ]
then
  echo "Environment-File: ${ENV_FILE} not found"

  while true; do
    read -p "Should I create a basic configuration? y/n?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done


fi

source ${ENV_FILE}

new() {

  if [[ ! -d "$(dirname ${ENV_FILE})" ]]; then
    mkdir -p "$(dirname ${ENV_FILE})"
  fi

  cat environments/_template/.env > "${ENV_FILE}"
  echo "Configuration create in ${ENV_FILE}"
  echo "Please fullfill desired properties and run this script again"
  exit 0
}

build_images() {

  # if [ "$CONTAINER_PREFIX" != "local" ]
  # then
  #   mv ${INFRA_PATH}/docker/appsrv/_binaries/* ${INFRA_PATH}/docker/appsrv/_binaries_tmp/ 2>/dev/null
  #   mv ${INFRA_PATH}/docker/appsrv/_binaries_tmp/note.md ${INFRA_PATH}/docker/appsrv/_binaries/ 2>/dev/null
  # else
  #   mv ${INFRA_PATH}/docker/appsrv/_binaries_tmp/* ${INFRA_PATH}/docker/appsrv/_binaries/ 2>/dev/null
  #   mv ${INFRA_PATH}/docker/appsrv/_binaries/note_tmp.md ${INFRA_PATH}/docker/appsrv/_binaries_tmp/ 2>/dev/null
  # fi


  # build images
  echo "Building images for environment: ${ENV_FILE}"
  ${COMPOSE_COMMAND} build ${OPTION}
}


start_services() {
  # startup containers
  echo "Building starting containers ${OPTION} for environment: ${ENV_FILE}"
  ${COMPOSE_COMMAND} up -d ${OPTION}

  echo_log
}

echo_log(){
  echo ""
  echo ""

  # only on remote you are able tu renew certificates
  if [ "$CONTAINER_PREFIX" != "local" ]
  then
    echo "view log-output enter   : ./remote.sh ${STACK} ${ENV_FILE} logs"
    echo "renew certificates enter: ./remote.sh ${STACK} ${ENV_FILE} renew"
    echo
    echo "On first start you should call ./remote.sh ${STACK} ${ENV_FILE} nginx"
    echo "to set vhost.d"
  else
    echo "view log-output enter   : ./local.sh logs"
  fi
}

log_services() {
  # logs -f
  if [ -z "$OPTION" ]
  then
    ${COMPOSE_COMMAND} logs -f
  else
    ${COMPOSE_COMMAND} logs -f $OPTION
  fi
}

list_services() {
  ${COMPOSE_COMMAND} ps
}

renew_certificate() {
  # renew cert
  ${COMPOSE_COMMAND} exec letsencrypt-nginx-proxy ./force_renew
}

writenginx() {
  ${COMPOSE_COMMAND} restart nginx-proxy
}


view_config() {
  ${COMPOSE_COMMAND} config
}

clear() {
  while true; do
    read -p "All containers, images, volume will be removed!!! Are you sure? y/n?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
  done

  # Remove containers and images
  ${COMPOSE_COMMAND} down -v --rmi all --remove-orphans

  # Clean
  docker volume prune
  docker system prune

}

print_compose() {
  echo ${COMPOSE_COMMAND}
}

stop_services() {
  ${COMPOSE_COMMAND} stop
}

exec_services() {
  ${COMPOSE_COMMAND} $OPTION
}

case ${COMMAND} in
  'build')
    build_images
    ;;
  'start')
    start_services
    ;;
  'run')
    build_images
    start_services
    ;;
  'logs')
    log_services
    ;;
  'renew')
    renew_certificate
    ;;
  'config')
    view_config
    ;;
  'clear')
    clear
    ;;
  'print')
    print_compose
    ;;
  'stop')
    stop_services
    ;;
  'list')
    list_services
    ;;
  'exec')
    exec_services
    ;;
  'nginx')
    writenginx
    ;;
  'new')
    new
    ;;
  *)
    ${COMMAND}
    ;;
esac