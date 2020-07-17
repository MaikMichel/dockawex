#!/bin/bash
THIS_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COME_FROM_DIR=${PWD}

# All Params are required
if [ $# -ne 4 ]; then
	echo "Please call script by using all params in this order!"
	echo "KEY_ID SECRET_KEY VPC_ID MACHINE_NAME"

  echo "1: $1"
  echo "2: $2"
  echo "3: $3"
  echo "4: $4"

	echo "Canceled !!!"
	exit
fi

# store instance-name
EC2_NAME=$4
EC2_TAG=$5

# credentials for awsdockeruser
# aws configure has to be called before
export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
export AWS_VPC_ID=$3

echo "###################################################"
echo "remove KeyPair if it exists $4"

# remove KeyPair if it exists
aws ec2 delete-key-pair --key-name $4

echo "###################################################"
echo "create instance ${EC2_NAME}"

# create instance
# > there was a bug in current version so take an older version
# --engine-install-url=https://web.archive.org/web/20170623081500/https://get.docker.com \
docker-machine -D create \
  --driver amazonec2 \
  --amazonec2-access-key ${AWS_ACCESS_KEY_ID} \
  --amazonec2-secret-key ${AWS_SECRET_ACCESS_KEY} \
  --amazonec2-vpc-id ${AWS_VPC_ID} \
  --amazonec2-region eu-central-1 \
  --amazonec2-root-size 32 \
  --amazonec2-instance-type t2.medium \
  --amazonec2-tags tag,${EC2_TAG} \
  ${EC2_NAME}

eval $(docker-machine env ${EC2_NAME})

echo "###################################################"
echo "EC2 is ready updating host"

docker-machine ssh ${EC2_NAME} sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y -u  -o Dpkg::Options::="--force-confdef" --allow-downgrades --allow-remove-essential --allow-change-held-packages --allow-change-held-packages --allow-unauthenticated

docker-machine ssh ${EC2_NAME} sudo timedatectl set-timezone Europe/Berlin

echo "###################################################"
echo "Config for using CloudWatch"

docker-machine ssh ${EC2_NAME} "touch /tmp/aws-credentials.conf"
docker-machine ssh ${EC2_NAME} "echo \"[Service]\" >> /tmp/aws-credentials.conf"
docker-machine ssh ${EC2_NAME} "echo 'Environment=\"AWS_ACCESS_KEY_ID=$1\"' >> /tmp/aws-credentials.conf"
docker-machine ssh ${EC2_NAME} "echo 'Environment=\"AWS_SECRET_ACCESS_KEY=$2\"' >> /tmp/aws-credentials.conf"

docker-machine ssh ${EC2_NAME} "sudo mkdir -p /etc/systemd/system/docker.service.d/"
docker-machine ssh ${EC2_NAME} "sudo mv /tmp/aws-credentials.conf /etc/systemd/system/docker.service.d/aws-credentials.conf"
docker-machine ssh ${EC2_NAME} "sudo systemctl daemon-reload"
docker-machine ssh ${EC2_NAME} "sudo service docker restart"


echo "###################################################"

# back to where we came from
cd "${COME_FROM_DIR}"
