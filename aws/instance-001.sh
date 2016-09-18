#!/bin/bash

## TODO function don't work!!! source/sh

set -e
set -x

# configuration

ACCOUNT="aws"
REGION="eu-central-1"
AVAILABILITY_ZONE="eu-central-1a"
#VOLUME_ID="vol-???"

# end of configuration


source ./utils.sh
TMP_FILE=$(mktemp --suffix .json)


# ireland
# CentOS 7.2 x86_64 with cloud-init (HVM) - ami-1f5dfe6c
# CentOS 7.2 x86_64 with cloud-init (PV) - ami-0c5ffc7f
# fankfurt
# CentOS 7.2 x86_64 with cloud-init (PV) - ami-87d2ceeb
# CentOS 7.2 x86_64 with cloud-init (HVM) - ami-96d2cefa

if [ -z "$VOLUME_ID" ]; then
  aws ec2 create-volume \
    --size 5 \
    --region ${REGION} --availability-zone ${AVAILABILITY_ZONE} \
    --volume-type gp2 > ${TMP_FILE}

  aws_get_volume_id
fi

# aws ec2 delete-volume --volume-id ${VOLUME_ID}
# aws ec2 describe-volumes

aws ec2 run-instances \
  --image-id ami-96d2cefa \
  --instance-type t2.micro \
  --region ${REGION} --placement AvailabilityZone=${AVAILABILITY_ZONE} \
  --key-name ${ACCOUNT} \
  --security-groups webserver dbserver administrable \
  > ${TMP_FILE}

aws_get_instance_id

aws_wait_instance

aws_get_instance_ip

# aws ec2 terminate-instances --instance-ids ${INSTANCE_ID}
# aws ec2 describe-instances

aws ec2 attach-volume --volume-id ${VOLUME_ID} --instance-id ${INSTANCE_ID} --device /dev/sdf

aws_add_to_known_hosts


ssh_until_sucesss

ssh -i ~/${ACCOUNT}.pem ec2-user@${INSTANCE_IP} "mkdir -p /home/ec2-user/vagrant/"
#scp -i ~/${ACCOUNT}.pem -pr ../ ec2-user@${INSTANCE_IP}:/home/ec2-user/vagrant/
rsync -azvv -e "ssh -i ~/${ACCOUNT}.pem" ../ ec2-user@${INSTANCE_IP}:/home/ec2-user/vagrant/

ssh -tt -i ~/${ACCOUNT}.pem ec2-user@${INSTANCE_IP} "bash -s -x -e" -- < ../prepare-instance.sh

for SH_FILE in "disable-selinux.sh" "node.sh" "git.sh" "dotfiles.sh" "ntp.sh" "nginx.sh" "mariadb.sh" "nginx-php.sh";
do
  echo "** Installing: ${SH_FILE}"
  ssh -i ~/${ACCOUNT}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < ../${SH_FILE}
done


ssh -i ~/${ACCOUNT}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < ../wordpress.sh --db-name=wordpress --db-user=wordpress --target-dir=/var/www/html/wp0
ssh -i ~/${ACCOUNT}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < ../wordpress-nginx.sh

#ssh -i ~/${ACCOUNT}.pem ec2-user@${INSTANCE_IP}

rm -f $TMP_FILE

echo "OK"
