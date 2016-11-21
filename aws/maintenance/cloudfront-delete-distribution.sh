#!/bin/sh

#this is a recipe atm not a script, follow the instructions
exit 1

# select first
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query 'DistributionList.Items[0].Id' --output text)
DISTRIBUTION_ETAG=$(aws cloudfront get-distribution-config --id ${DISTRIBUTION_ID} --query 'ETag' --output text)
aws cloudfront get-distribution-config --id ${DISTRIBUTION_ID} --query 'DistributionConfig' > /tmp/disable-distribution
# manualy edit "Enabled": false -> true
aws cloudfront update-distribution --id ${DISTRIBUTION_ID} --if-match ${DISTRIBUTION_ETAG} --distribution-config file:///tmp/disable-distribution

# wait until in not InProgress, then we can delete
STATUS="InProgress"
while [ "${STATUS}" == "InProgress" ]
do
  STATUS=$(aws cloudfront list-distributions --query 'DistributionList.Items[0].Status' --output text)
  echo "status: ${STATUS}"
  sleep 5
done

# get the new etag & wait a few minutes...
DISTRIBUTION_ETAG=$(aws cloudfront get-distribution-config --id ${DISTRIBUTION_ID} --query 'ETag' --output text)
aws cloudfront delete-distribution --id ${DISTRIBUTION_ID} --if-match ${DISTRIBUTION_ETAG}
