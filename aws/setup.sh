#!/bin/sh

# initial setup for my aws clients after `aws configure`

set -x
set -e


ACCOUNT="aws"

echo "Using account: ${ACCOUNT}"

aws ec2 create-key-pair --key-name $ACCOUNT --query 'KeyMaterial' --output text > ~/${ACCOUNT}.pem
chmod 400 ~/${ACCOUNT}.pem

aws ec2 describe-key-pairs --key-name $ACCOUNT


aws ec2 create-security-group --group-name webserver --description "open port 80/443"
aws ec2 create-security-group --group-name dbserver --description "open port 3306"
aws ec2 create-security-group --group-name administrable --description "open everything to admin ips"

aws ec2 authorize-security-group-ingress --group-name dbserver --protocol tcp --port 3306 --source-group webserver

aws ec2 authorize-security-group-ingress --group-name webserver --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name webserver --protocol tcp --port 443 --cidr 0.0.0.0/0
