#!/bin/sh

MY_IP=$(wget http://ipinfo.io/ip -qO -)

echo "My ip: ${MY_IP}"

# TODO revoke everything in administrable
# aws ec2 revoke-security-group-ingress --group-name administrable

aws ec2 authorize-security-group-ingress --group-name administrable --protocol tcp --port 22 --cidr ${MY_IP}/32	

aws ec2 describe-security-groups --group-name administrable

echo "OK"