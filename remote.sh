#!/bin/bash

# All Params are required
if [ $# -lt 5 ]; then
  echo
  echo "Usage $0 full|dev switch|no_switch machine-prov-file machine-name command"
  echo
  echo "  full|dev "
  echo "    > full: all containers (nginx, lets'encrypt)"
  echo "    > dev:  only db, appsrv and node-proxy"
  echo
  echo "  switch|no_switch "
  echo "    > switch: use docker-machine to switch to machine"
  echo "    > no_switch: without remote-compose (nginx, lets'encrypt)"
  echo
  echo "  machine-prov-file "
  echo "    > file used by docker-machine driver (aws, digitalocean)"
  echo "      if not exists then no machine will be created"
  echo
  echo "  machine-name "
  echo "    > name of ec2-instance / droplet"
  echo
  echo "  command "
  echo "    > create > creates only ec2-instance"
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
  echo "    > remove > remove machine"
  echo "    > exec   > calls compose only and attach params"
  echo "    > new    > generates new machine folder with default.env"
  echo
  echo
  exit 1
fi

STACK=$1
SWITCH=$2
MACHINE_PROVIDER=$3
MACHINE_NAME=$4
COMMAND=$5
OPTION=$6

export CONTAINER_PREFIX=${MACHINE_NAME}

# path
INFRA_PATH="infrastructure"

if [ "${STACK}" == "full" ]
then
  COMPOSE_COMMAND="docker-compose -p ${MACHINE_NAME} -f ${INFRA_PATH}/docker/docker-compose.yml -f ${INFRA_PATH}/docker/docker-compose-remote.yml -f ${INFRA_PATH}/docker/custom-compose.yml"
else
  COMPOSE_COMMAND="docker-compose -p ${MACHINE_NAME} -f ${INFRA_PATH}/docker/docker-compose.yml -f ${INFRA_PATH}/docker/docker-compose-local.yml -f ${INFRA_PATH}/docker/custom-compose.yml"
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


if [ -e ${MACHINE_PROVIDER} ]
then
  source ${MACHINE_PROVIDER}
fi


source machines/${MACHINE_NAME}/.env


switch_to_machine(){
  if [[ "$SWITCH" != "no_switch" ]]
  then    
    echo "Switching to machine: ${MACHINE_NAME}"
    docker-machine env --shell bash ${MACHINE_NAME}
    eval $(docker-machine env --shell bash ${MACHINE_NAME})
  fi
}


create_machine() {
  if ( [[ "$MACHINE_NAME" != "default" ]] && [[ -e ${MACHINE_PROVIDER} ]] )
  then
    echo "Creating machine: ${MACHINE_NAME} / DriverType: $DRIVER_TYPE"
    if [ "$DRIVER_TYPE" == "AWS" ]
    then
      ${INFRA_PATH}/create_ec2_instance.sh ${ACCESS_KEY_ID} ${SECRET_ACCESS_KEY} ${VPC_ID} ${MACHINE_NAME}
    else
      ${INFRA_PATH}/create_drp_instance.sh ${OCEAN_TOKEN} ${MACHINE_NAME} ${OCEAN_TAG}
    fi
  else
    echo "Machine $MACHINE_NAME will not be created"
    if ! [[ -e ${MACHINE_PROVIDER} ]]
    then
      echo "File ${MACHINE_PROVIDER} does not exist"
    fi
  fi
}

build_images() {

  if [ "$MACHINE_NAME" != "default" ]
  then
    mv ${INFRA_PATH}/docker/appsrv/_binaries/* ${INFRA_PATH}/docker/appsrv/_binaries_tmp 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries/* ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb11xe/_binaries/* ${INFRA_PATH}/docker/oradb11xe/_binaries_tmp 2>/dev/null

    mv ${INFRA_PATH}/docker/appsrv/_binaries_tmp/note.md ${INFRA_PATH}/docker/appsrv/_binaries 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp/note.md ${INFRA_PATH}/docker/oradb18xe/_binaries 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb11xe/_binaries_tmp/note.md ${INFRA_PATH}/docker/oradb11xe/_binaries 2>/dev/null
  else
    mv ${INFRA_PATH}/docker/appsrv/_binaries_tmp/* ${INFRA_PATH}/docker/appsrv/_binaries 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp/* ${INFRA_PATH}/docker/oradb18xe/_binaries 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb11xe/_binaries_tmp/* ${INFRA_PATH}/docker/oradb11xe/_binaries 2>/dev/null

    mv ${INFRA_PATH}/docker/appsrv/_binaries/note_tmp.md ${INFRA_PATH}/docker/appsrv/_binaries_tmp 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb18xe/_binaries/note_tmp.md ${INFRA_PATH}/docker/oradb18xe/_binaries_tmp 2>/dev/null
    mv ${INFRA_PATH}/docker/oradb11xe/_binaries/note_tmp.md ${INFRA_PATH}/docker/oradb11xe/_binaries_tmp 2>/dev/null
  fi

  switch_to_machine

  # build images
  echo "Building images for machine: ${MACHINE_NAME}"
  ${COMPOSE_COMMAND} build ${OPTION}
}


start_services() {
  switch_to_machine
    
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
    echo "to set vhosd.d"
  else
    echo "view log-output enter   : ./local.sh logs"
  fi
}

log_services() {
  switch_to_machine

  # logs -f
  if [ -z "$OPTION" ]
  then
    ${COMPOSE_COMMAND} logs -f
  else
    ${COMPOSE_COMMAND} logs -f $OPTION
  fi
}

list_services() {
  switch_to_machine

  ${COMPOSE_COMMAND} ps
}

renew_certificate() {
  switch_to_machine

  # renew cert
  ${COMPOSE_COMMAND} exec letsencrypt-nginx-proxy ./force_renew
}

writenginx() {
  switch_to_machine

  ${COMPOSE_COMMAND} restart nginx-proxy
  
}


view_config() {
  ${COMPOSE_COMMAND} config
}

clear_machine() {
  switch_to_machine

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

remove_machine() {
  # we won't remove your default
  if [ "$MACHINE_NAME" != "default" ]
  then
    docker-machine rm -f ${MACHINE_NAME}
  fi

  # eval $(docker-machine env -u)
}

print_compose() {
  echo ${COMPOSE_COMMAND}
}

stop_services() {
  switch_to_machine

  ${COMPOSE_COMMAND} stop
}

exec_services() {
  switch_to_machine

  ${COMPOSE_COMMAND} $OPTION
}

case ${COMMAND} in
  'create')
    create_machine
    ;;
  'build')
    build_images
    ;;
  'start')
    start_services
    ;;
  'run')
    create_machine
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
  'remove')
    remove_machine
    ;;
  'clear')
    clear_machine
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