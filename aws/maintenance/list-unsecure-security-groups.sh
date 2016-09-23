#!/bin/bash

# credits - https://cloudonaut.io/diy-aws-security-review/

sgs=$(aws ec2 describe-security-groups --filters "Name=ip-permission.cidr,Values=0.0.0.0/0" --query "SecurityGroups[].[GroupId, GroupName]" --output text)

while read -r line; do
    sgid=$(echo $line | awk '{print $1;}')
    sgname=$(echo $line | awk '{print $2;}')
    c=$(aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$sgid" --query "length(NetworkInterfaces)" --output text)
    echo "$sgid,$c,$sgname"
done <<< "$sgs"
