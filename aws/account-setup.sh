#!/bin/sh

# steps
# `aws configure`
# `vi set-global-vars.sh` # edit profile!
# `sh set-global-vars.sh`
# initial setup for my aws clients

set -exuo pipefail

source "$(dirname "$0")/utils.sh"
aws_prerequisites

echo "Using account: ${AWS_CLIENT_ID}"

if [ -f ~/.ssh/${AWS_CLIENT_PEM}.pem ]
then
  echo "Using key pair: ${AWS_CLIENT_PEM}"
else
  echo "Create key pair: ${AWS_CLIENT_PEM}"
  aws ec2 create-key-pair --key-name $AWS_CLIENT_PEM --query 'KeyMaterial' --output text > ~/.ssh/${AWS_CLIENT_PEM}.pem  
fi

chmod 400 ~/.ssh/${AWS_CLIENT_PEM}.pem
# aws ec2 describe-key-pairs --key-name $AWS_CLIENT_PEM

echo "Create & Configure security groups"
# NOTE if the account is very old you may need to include --vpc-id
# and lambda config may fail...
EC2_GID=$(aws ec2 create-security-group --group-name ec2 --description "ec2 servers" --query GroupId --output text)
WEBSERVER_GID=$(aws ec2 create-security-group --group-name webserver --description "open port 80/443" --query GroupId --output text)
DBSERVER_GID=$(aws ec2 create-security-group --group-name dbserver --description "open port 3306" --query GroupId --output text)
ADMINISTRABLE_GID=$(aws ec2 create-security-group --group-name administrable --description "open everything to admin ips" --query GroupId --output text)
LAMBDA_GROUP_ID=$(aws ec2 create-security-group --group-name lambda --description "open port 22" --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id ${DBSERVER_GID} --protocol tcp --port 3306 --source-group ${WEBSERVER_GID}

aws ec2 authorize-security-group-ingress --group-id ${WEBSERVER_GID} --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${WEBSERVER_GID} --protocol tcp --port 443 --cidr 0.0.0.0/0

# authorize lamnda to call ec2 servers via ssh
# TODO webserver & dbserver should be removed asap, when new ec2 group enters in prod
for GROUP_NAME in "ec2" "webserver" "dbserver";
do
  GROUP_ID=$(aws ec2 describe-security-groups --group-names "${GROUP_NAME}" \
    --query 'SecurityGroups[0].GroupId' --output text)

  tee /tmp/json <<EOF >/dev/null
  [{
    "IpProtocol": "tcp",
    "FromPort": 22,
    "ToPort": 22,
    "UserIdGroupPairs": [{
      "GroupId": "${GROUP_ID}"
    }]
  }]
EOF
  aws ec2 authorize-security-group-ingress --group-name ${GROUP_NAME}  --protocol tcp --port 22 --source-group lambda

  aws ec2 authorize-security-group-egress \
    --group-id ${LAMBDA_GROUP_ID} \
    --ip-permissions file:///tmp/json
done

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

# key-value database for lambda storage
aws dynamodb create-table --table-name lambda \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1


# create user for codecommit

# there are some manual steps in the local machine
# http://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html

#aws iam create-user --user-name llafuente
##aws iam create-access-key --user-name llafuente
#SSH_KEY=`cat ~/.ssh/github_rsa.pub`
#aws iam upload-ssh-public-key --user-name llafuente --ssh-public-key-body
