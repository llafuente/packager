#!/bin/bash

function aws_prerequisites {
  if [ -z ${AWS_CLIENT_PEM} ]; then
    echo "undefined AWS_CLIENT_PEM"
    echo "edit and execute set-global-vars.sh"
    exit 1
  fi
}

function aws_get_volume_id {
  VOLUME_ID=$(node -e "console.log(require('${TMP_FILE}').VolumeId)")
  echo "Volume found: ${VOLUME_ID}"
}

function aws_get_instance_id {
  INSTANCE_ID=$(node -e "console.log(require('${TMP_FILE}').Instances[0].InstanceId)")
  echo "Instance found: ${INSTANCE_ID}"
}

function aws_get_instance_ip {
  aws ec2 describe-instances \
    --filters "Name=instance-id,Values=${INSTANCE_ID}" \
    > ${TMP_FILE}

    cat ${TMP_FILE}

  INSTANCE_IP=$(node -e "console.log(require('${TMP_FILE}').Reservations[0].Instances[0].PublicDnsName)")
}

function aws_add_to_known_hosts {
  # avoid interactive yes/no known host
  touch ~/.ssh/known_hosts
  chmod 777 ~/.ssh/known_hosts

  ssh-keyscan -t rsa -H ${INSTANCE_IP} >> ~/.ssh/known_hosts
}

function aws_wait_instance {
  STATE="pending"
  while [ "${STATE}" == "pending" ]
  do
    aws ec2 describe-instances \
      --filters "Name=instance-id,Values=${INSTANCE_ID}" \
      > ${TMP_FILE}

      cat ${TMP_FILE}

    STATE=$(node -e "console.log(require('${TMP_FILE}').Reservations[0].Instances[0].State.Name)")
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
