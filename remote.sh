#!/bin/bash

# All Params are required
if [ $# -lt 3 ]; then
  echo
  echo "Usage $0 full|dev switch|no_switch machine-prov-file machine-name command"
  echo
  echo "  full|dev "
  echo "    > full: all containers (nginx, lets'encrypt)"
  echo "    > dev:  only db, appsrv and node-proxy"
  echo
  echo "  machine-name "
  echo "    > here is environment file located "
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
  echo "    > new    > generates new machine folder with default.env"
  echo
  echo
  exit 1
fi

STACK=$1
MACHINE_NAME=$2
COMMAND=$3
OPTION=$4

export CONTAINER_PREFIX=${MACHINE_NAME}

# path
INFRA_PATH="infrastructure"

if [ "${STACK}" == "full" ]
then
  COMPOSE_COMMAND="docker-compose -p ${MACHINE_NAME} -f ${INFRA_PATH}/docker/docker-compose.yml -f ${INFRA_PATH}/docker/docker-compose-remote.yml -f ${INFRA_PATH}/docker/custom-compose.yml"
else
  COMPOSE_COMMAND="docker-compose -p ${MACHINE_NAME} -f ${INFRA_PATH}/docker/docker-compose.yml -f ${INFRA_PATH}/docker/custom-compose.yml"
fi

if [ ! -f "machines/${MACHINE_NAME}/.env" ]
then
  echo "Machine: ${MACHINE_NAME} not found inside machines."

  while true; do
    read -p "Should I create a basic configuration? y/n?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done

  [ ! -d "machines/${MACHINE_NAME}" ] && mkdir "machines/${MACHINE_NAME}"
  cat machines/_template/.env > "machines/${MACHINE_NAME}/.env"
  echo "Configuration create in machines/${MACHINE_NAME}/.env"
  echo "Please fullfill desired properties and run that script again"
  exit 0
fi

source machines/${MACHINE_NAME}/.env


build_images() {

  if [ "$MACHINE_NAME" != "default" ]
  then
    mv ${INFRA_PATH}/docker/appsrv/_binaries/* ${INFRA_PATH}/docker/appsrv/_binaries_tmp 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries/* ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp 2>/dev/null

    mv ${INFRA_PATH}/docker/appsrv/_binaries_tmp/note.md ${INFRA_PATH}/docker/appsrv/_binaries 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp/note.md ${INFRA_PATH}/docker/oradb18xe/_binaries 2>/dev/null
  else
    mv ${INFRA_PATH}/docker/appsrv/_binaries_tmp/* ${INFRA_PATH}/docker/appsrv/_binaries 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp/* ${INFRA_PATH}/docker/oradb18xe/_binaries 2>/dev/null

    mv ${INFRA_PATH}/docker/appsrv/_binaries/note_tmp.md ${INFRA_PATH}/docker/appsrv/_binaries_tmp 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries/note_tmp.md ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp 2>/dev/null
  fi



  # build images
  echo "Building images for machine: ${MACHINE_NAME}"
  ${COMPOSE_COMMAND} build ${OPTION}
}


start_services() {
  # startup containers
  echo "Building starting containers ${OPTION} for machine: ${MACHINE_NAME}"
  #echo "${COMPOSE_COMMAND} up -d ${OPTION}"
  ${COMPOSE_COMMAND} up -d ${OPTION}

  echo_log
}

echo_log(){
  echo ""
  echo ""

  # only on remote you are able tu renew certificates
  if [ "$MACHINE_NAME" != "default" ]
  then
    echo "view log-output enter   : ./remote.sh ${STACK} ${SWITCH} ${MACHINE_PROVIDER} ${MACHINE_NAME} logs"
    echo "renew certificates enter: ./remote.sh ${STACK} ${SWITCH} ${MACHINE_PROVIDER} ${MACHINE_NAME} renew"
    echo
    echo "On first start you should call ./remote.sh ${STACK} ${SWITCH} ${MACHINE_PROVIDER} ${MACHINE_NAME} nginx"
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
  *)
    ${COMMAND}
    ;;
esac