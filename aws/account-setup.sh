#!/bin/bash

# steps
# `aws configure`
# `vi set-global-vars.sh` # edit profile!
# `sh set-global-vars.sh`
# initial setup for my aws clients

set -e
set -x

if [ -z ${AWS_CLIENT_PEM} ]; then
  echo "undefined AWS_CLIENT_PEM"
  echo "aws configure, edit and execute set-global-vars.sh"
  exit 1
fi

echo "Using account: ${AWS_CLIENT_ID}"

echo "Create key pair: ${AWS_CLIENT_PEM}"
aws ec2 create-key-pair --key-name $AWS_CLIENT_PEM --query 'KeyMaterial' --output text > ~/.ssh/${AWS_CLIENT_PEM}.pem
chmod 400 ~/.ssh/${AWS_CLIENT_PEM}.pem
# aws ec2 describe-key-pairs --key-name $AWS_CLIENT_PEM

echo "Create & Configure security groups"
aws ec2 create-security-group --group-name webserver --description "open port 80/443"
aws ec2 create-security-group --group-name dbserver --description "open port 3306"
aws ec2 create-security-group --group-name administrable --description "open everything to admin ips"

aws ec2 authorize-security-group-ingress --group-name dbserver --protocol tcp --port 3306 --source-group webserver

aws ec2 authorize-security-group-ingress --group-name webserver --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name webserver --protocol tcp --port 443 --cidr 0.0.0.0/0

echo "Create lambda role for cron operations"
aws iam create-role \
  --role-name role-lambda-cronuser \
  --assume-role-policy-document "file://$(pwd)/assume-role-lambda-cronuser.json"


aws iam put-role-policy \
  --role-name role-lambda-cronuser \
  --policy-name Ec2FullAccess --policy-document "file://$(pwd)/policy-ec2-full-access.json"

# aws iam update-assume-role-policy \
#   --role-name role-lambda-cronuser \
#   --policy-document "file://$(pwd)/role-lambda-cronuser-trust.json"
# aws iam delete-role --role-name role-lambda-cronuser


echo "Create S3 Bucket for lamnda code deploy"
# NOTE unused ATM
# for lambda s3 usage, i prefer zip deploy atm
aws s3api create-bucket \
  --bucket "${AWS_CLIENT_ID}-aws-lambda" \
  --acl private \
  --region eu-west-1 \
  --create-bucket-configuration "LocationConstraint=EU"

aws s3api create-bucket \
  --bucket "${AWS_CLIENT_ID}-logrotate" \
  --acl private \
  --region eu-west-1 \
  --create-bucket-configuration "LocationConstraint=EU"

echo "Create cron events"
# Run at 6:00/18:00 am (UTC) every day
aws events put-rule \
--name twice-day \
--schedule-expression "cron(0 6/12 * * ? *)"

# Run at 5:00 am (UTC) every day
aws events put-rule \
  --name "daily" \
  --schedule-expression "cron(0 5 * * ? *)"

# Run at 4:00 am (UTC) every sunday
aws events put-rule \
--name weekly \
--schedule-expression "cron(0 4 * * 1 *)"

# Run at 3:00 am (UTC) every 1st of each month
aws events put-rule \
--name monthly \
--schedule-expression "cron(0 3 1 * ? *)"

echo "Create instance role logrotate"
aws iam create-role \
  --role-name role-logrotate \
  --assume-role-policy-document "file://$(pwd)/assume-role-logrotate.json"

TMP=$(mktemp)
cp policy-s3-bucket-full-access.json ${TMP}
sed -i "s/target-bucket/${AWS_CLIENT_ID}-logrotate/g" ${TMP}

aws iam put-role-policy \
  --role-name role-logrotate \
  --policy-name S3FullAccess --policy-document "file://${TMP}"

rm -f ${TMP}

aws iam create-instance-profile \
  --instance-profile-name profile-logrotate

aws iam add-role-to-instance-profile \
  --instance-profile-name profile-logrotate \
  --role-name role-logrotate