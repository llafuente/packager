#!/bin/sh

# declare utils functions

function aws_prerequisites {
  if [ -z ${AWS_CLIENT_PEM} ]; then
    echo "undefined AWS_CLIENT_PEM"
    echo "edit and execute ~/.aws-profile"
    exit 1
  fi
  if [ -z ${INSTALLER_ROOT} ]; then
    echo "undefined INSTALLER_ROOT"
    echo "edit and execute ~/.aws-profile"
    exit 1
  fi
  
}

function aws_get_instance_ip {
  export INSTANCE_IP=$(aws ec2 describe-instances \
    --filters "Name=instance-id,Values=${INSTANCE_ID}" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
  echo "INSTANCE_IP=${INSTANCE_IP}"
}

function aws_add_to_known_hosts {
  # avoid interactive yes/no known host
  touch ~/.ssh/known_hosts
  chmod 777 ~/.ssh/known_hosts

  KNOW_HOSTS_LINE=$(ssh-keyscan -t rsa -H ${INSTANCE_IP})

  if [ -z ${KNOW_HOSTS_LINE} ]; then
    echo "Cannot have access to the instance. Open the firewall"
    exit 1
  fi

  TEST=$(echo ${KNOW_HOSTS_LINE} | cut -d ' ' -f 3)
  TEST=$(grep "${TEST}" ~/.ssh/known_hosts)
  if [ -z "$TEST" ]; then
    echo ${KNOW_HOSTS_LINE} | tee -a ~/.ssh/known_hosts
  fi
}

function aws_wait_instance {
  STATE="pending"
  while [ "${STATE}" == "pending" ]
  do
    STATE=$(aws ec2 describe-instances \
      --filters "Name=instance-id,Values=${INSTANCE_ID}" \
      --query 'Reservations[0].Instances[0].State.Name' --output text)
    sleep 1
  done
}


function ssh_until_sucesss {
  local repeat="true"
  while "$repeat"; do
    sleep 5
    echo "new ssh attempt..."
    ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "exit" && repeat=false
  done
}


function get_ami {
  # TODO choose dynamically
  # N. Virginia
  # CentOS 7.2 x86_64 with cloud-init (PV) - ami-0fbdf765
  # CentOS 7.2 x86_64 with cloud-init (HVM) - ami-83bdf7e9
  # 
  # Ireland
  # CentOS 7.2 x86_64 with cloud-init (PV) - ami-0c5ffc7f
  # CentOS 7.2 x86_64 with cloud-init (HVM) - ami-1f5dfe6c
  #
  # Fankfurt
  # CentOS 7.2 x86_64 with cloud-init (PV) - ami-87d2ceeb
  # CentOS 7.2 x86_64 with cloud-init (HVM) - ami-96d2cefa
  if [ ${AWS_DEFAULT_REGION} == "us-east-1" ]
  then
    echo "ami-83bdf7e9"
  elif [ ${AWS_DEFAULT_REGION} == "eu-central-1" ]
  then
    echo "ami-96d2cefa"
  elif [ ${AWS_DEFAULT_REGION} == "eu-central-1" ]
  then
    echo "ami-96d2cefa"
  fi
}