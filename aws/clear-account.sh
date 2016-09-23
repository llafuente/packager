#!/bin/sh

# try to clean everything in you AWS account region

INSTANCE_IDS=$(aws ec2 describe-instances --query Reservations[*].Instances[*].InstanceId --output text)

aws ec2 terminate-instances --instance-ids ${INSTANCE_IDS}

VOLUME_IDS=$(aws ec2 describe-volumes --query 'Volumes[*].VolumeId' --output text)

for VOLUME_ID in ${VOLUME_IDS};
do
  aws ec2 delete-volume --volume-id ${VOLUME_ID}
done

OWNER_ID=$(aws iam get-user --query User.Arn --output text | cut -c14- | cut -c-12)

SNAPSHOT_IDS=$(aws ec2 describe-snapshots --owner-ids ${OWNER_ID} --query 'Snapshots[*].SnapshotId' --output text)

for SNAPSHOT_ID in ${SNAPSHOT_IDS};
do
  aws ec2 delete-snapshot --snapshot-id ${SNAPSHOT_ID}
done


BUCKETS=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

for BUCKET in ${BUCKETS};
do
  put-bucket-versioning --bucket ${BUCKET} --versioning-configuration 'MFADelete=Disabled,Status=Suspended'
  aws s3 rb "s3://${BUCKET}" --force

  # alternative? untested
  # aws s3 rm s3://bucket-name/doc --recursive
  # aws s3api delete-bucket --bucket my-bucket --region us-east-1
done


KEYS=$(aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text)

for KEY in ${KEYS};
do
  aws ec2 delete-key-pair --key-name ${KEY}
done


SECURITY_GROUPS=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].GroupId' --output text)

for SECURITY_GROUP in ${SECURITY_GROUPS};
do
  aws ec2 delete-security-group --group-id ${SECURITY_GROUP}
done


PROFILE_NAMES=$(aws iam list-instance-profiles --query 'InstanceProfiles[*].InstanceProfileName' --output text)
for PROFILE_NAME in ${PROFILE_NAMES};
do
  aws iam delete-instance-profile --instance-profile-name {PROFILE_NAME}
done


ROLE_NAMES=$(aws iam list-roles --query 'Roles[*].RoleName' --output text)
for ROLE_NAME in ${ROLE_NAMES};
do
  aws iam delete-role --role-name ${ROLE_NAME}
done


USER_NAMES=$(aws iam list-users --query 'Users[*].UserName' --output text)
for USER_NAME in ${USER_NAMES};
do
  aws iam delete-user --user-name ${USER_NAME}
done


ROLE_NAMES=$(aws events list-rules --query 'Rules[*].Name' --output text)
for ROLE_NAME in ${ROLE_NAMES};
do
  aws events list-rules --name ${ROLE_NAME}
done


FUNCTION_NAMES=$(aws lambda list-functions --query 'Functions[*].FunctionName' --output text)
for FUNCTION_NAME in ${FUNCTION_NAMES};
do
  aws lambda delete-function --function-name ${FUNCTION_NAME}
done
