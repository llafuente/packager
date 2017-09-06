#!/bin/sh

set -exuo pipefail

for BUCKET in $(aws s3 ls | awk '{print $3}')
do
	mkdir -p ${HOME}/s3/${BUCKET}
	aws s3 sync s3://${BUCKET} ${HOME}/s3/${BUCKET}
done