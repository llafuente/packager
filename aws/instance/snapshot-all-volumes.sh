#!/bin/sh

#create an snapshot for all volumes found in the current instance

INSTANCE_ID=$(curl http://instance-data/latest/meta-data/instance-id)

VOLUME_IDS=$(aws ec2 describe-volumes \
  --filters "Name=volume-id,Values=${INSTANCE_ID}" | node -e "require('curt').stdin((t) => { t.Volumes.each((v) => { stdout(v.VolumeId) } }, 'json')")

DELETE_ON=$(date --date="next week" +"%Y-%m-%d")

for VOLUME_ID in ${VOLUME_IDS};
do
  aws ec2 create-tags
  --resources ${VOLUME_ID} \
  --tags "Key=DeleteOn,Value=${DELETE_ON}"
done
