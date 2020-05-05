#!/bin/bash

echo "Your script args ($#) are: $@"

THIS_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COME_FROM_DIR=${PWD}

# All Params are required
if [ $# -lt 2 ]; then
	echo "Please call script by using all params in this order!"
	echo "OCEAN_TOKEN MACHINE_NAME"

  echo "1: $1"
  echo "2: $2"
  
	echo "Canceled !!!"
	exit
fi

# store instance-name
OCEAN_DROPLET_NAME=$2
OCEAN_TOKEN=$1
OCEAN_TAG=$3
echo "###################################################"
echo "create instance ${OCEAN_DROPLET_NAME}"

docker-machine -D create --driver digitalocean --digitalocean-size "s-2vcpu-4gb" --digitalocean-region "ams3" --digitalocean-access-token ${OCEAN_TOKEN} --digitalocean-tags ${OCEAN_TAG} ${OCEAN_DROPLET_NAME}

eval $(docker-machine env ${OCEAN_DROPLET_NAME})

docker-machine ssh ${OCEAN_DROPLET_NAME} sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y -u  -o Dpkg::Options::="--force-confdef" --allow-downgrades --allow-remove-essential --allow-change-held-packages --allow-change-held-packages --allow-unauthenticated
docker-machine ssh ${OCEAN_DROPLET_NAME} sudo timedatectl set-timezone Europe/Berlin

docker-machine ssh ${OCEAN_DROPLET_NAME} mkdir -p /home/oracle/oradata
docker-machine ssh ${OCEAN_DROPLET_NAME} chmod a+w /home/oracle/oradata

echo " ----------------------------------------"
echo " ========================================"
echo " Droplet erstellt: ${OCEAN_DROPLET_NAME}"
echo " ========================================"
echo " ----------------------------------------"
# back to where we came from
cd "${COME_FROM_DIR}"
