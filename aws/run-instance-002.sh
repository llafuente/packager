#!/bin/sh

set -exuo pipefail

source ./utils.sh
aws_prerequisites

# configuration
# restore this volume!
# VOLUME_ID="vol-???"

# end of configuration

# ireland
# CentOS 7.2 x86_64 with cloud-init (HVM) - ami-1f5dfe6c
# CentOS 7.2 x86_64 with cloud-init (PV) - ami-0c5ffc7f
# fankfurt
# CentOS 7.2 x86_64 with cloud-init (PV) - ami-87d2ceeb
# CentOS 7.2 x86_64 with cloud-init (HVM) - ami-96d2cefa

#TODO  --iam-instance-profile profile-logrotate \
export INSTANCE_ID=$(aws ec2 run-instances \
  --image-id ami-96d2cefa \
  --instance-type t2.micro \
  --region ${AWS_DEFAULT_REGION} --placement AvailabilityZone=${AWS_AVAILABILITY_ZONE} \
  --key-name ${AWS_CLIENT_PEM} \
  --security-groups ec2 webserver dbserver administrable \
  --query 'Instances[0].InstanceId' --output text)

aws_wait_instance

aws ec2 create-tags --resources ${INSTANCE_ID} --tags "Key=Name,Value=webserver02"

VOLUME_INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=instance-id,Values=${INSTANCE_ID}" \
  --query 'Reservations[0].Instances[0].BlockDeviceMappings[*].Ebs.VolumeId' --output text)
#  | node -e "require('curt').stdin((x) => { stdout(_.map(x.Reservations[0].Instances[0].BlockDeviceMappings, 'Ebs.VolumeId').join(' ')); }, 'json')")

aws_get_instance_ip

if [ -z "${VOLUME_ID}" ]; then
  echo "Create volume"
  export VOLUME_ID=$(aws ec2 create-volume \
    --size 5 \
    --region ${AWS_DEFAULT_REGION} --availability-zone ${AWS_AVAILABILITY_ZONE} \
    --volume-type gp2 \
    --query VolumeId --output text)
fi

aws ec2 attach-volume --volume-id ${VOLUME_ID} --instance-id ${INSTANCE_ID} --device /dev/xvdf

aws_add_to_known_hosts

ssh_until_sucesss

export SSH_FILE="ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP}"

ssh -tt -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < \
  ${INSTALLER_ROOT}/packages/prepare-instance.sh

ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "mkdir -p /home/ec2-user/packager/"

rsync -qazvv -e "ssh -i ${HOME}/.ssh/${AWS_CLIENT_PEM}.pem" ${INSTALLER_ROOT} ec2-user@${INSTANCE_IP}:/home/ec2-user/packager/

for SH_FILE in "disable-selinux.sh" "node.sh" "git.sh" "dotfiles.sh" "ntp.sh" "mongodb.sh" "ruby.sh";
do
  echo "** Installing: ${SH_FILE}"
  ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < \
    ${INSTALLER_ROOT}/packages/${SH_FILE}
done

ssh -i ~/.ssh/${AWS_CLIENT_PEM}.pem ec2-user@${INSTANCE_IP} "bash -s" -- < \
  ./mount-ebs.sh --device=xvdf

aws ec2 create-tags --resources ${VOLUME_ID} --tags "Key=mongodb,Value=true"

echo "OK"
