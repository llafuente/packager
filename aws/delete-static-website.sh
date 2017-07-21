#!/bin/sh

set -exuo pipefail

for i in "$@"
do
case $i in
  --id=*)
    DISTRIBUTION_ID="${i#*=}"
    shift # past argument=value
  ;;
  --domain=*)
    DOMAIN="${i#*=}"
    shift # past argument=value
  ;;
  *)
    # unknown option
  ;;
esac
done

if [ -z ${DOMAIN} ]; then
  echo "--domain is required"
  echo "KO"
  exit 1
fi

# dev: select first, if you have a clean aws account this is useful :)
# DISTRIBUTION_ID=$(aws cloudfront list-distributions \
#   --query 'DistributionList.Items[0].Id' --output text)

if [ ! -z ${DISTRIBUTION_ID} ]; then

  DISTRIBUTION_ETAG=$(aws cloudfront get-distribution-config \
    --id ${DISTRIBUTION_ID} --query 'ETag' --output text)

  aws cloudfront get-distribution-config --id ${DISTRIBUTION_ID} \
    --query 'DistributionConfig' > /tmp/dist-config.json

  sed -i 's/    "Enabled": true,/    "Enabled": false,/g' /tmp/dist-config.json

  echo "disable configuration for: ${DISTRIBUTION_ID} / ${DISTRIBUTION_ETAG}"
  STATUS=$(aws cloudfront update-distribution --id ${DISTRIBUTION_ID} \
    --if-match ${DISTRIBUTION_ETAG} \
    --distribution-config file:///tmp/dist-config.json \
    --query 'Distribution.Status' --output text)
  # wait until in not InProgress, then we can delete
  echo "${DISTRIBUTION_ID}.Status = ${STATUS}"
  while [ "${STATUS}" = "InProgress" ]
  do
    STATUS=$(aws cloudfront list-distributions \
      --query 'DistributionList.Items[0].Status' --output text)
    echo "."
    sleep 5
  done
  # while doing some testing this fail to me a few times
  # maybe this sleep some more is what aws need to properly delete...
  sleep 5
  # get the new etag & wait a few minutes...
  DISTRIBUTION_ETAG=$(aws cloudfront get-distribution-config \
    --id ${DISTRIBUTION_ID} --query 'ETag' --output text)
  sleep 5
  aws cloudfront delete-distribution --id ${DISTRIBUTION_ID} \
    --if-match ${DISTRIBUTION_ETAG}

fi

aws s3 rb s3://${DOMAIN} --force
aws s3 rb s3://www.${DOMAIN} --force
# aws s3 ls
