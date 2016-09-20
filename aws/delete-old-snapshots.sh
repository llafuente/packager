#!/bin/sh

# list all tags related to snapshots

DELETE_ON=$(date +"%Y-%m-%d")

# scope in node to compare dates and print volume_id(s)
SCRIPT=$(cat << EOM
require('curt').stdin((a) => {
  a.Tags.each((v) => {
    if (v.Key == 'DeleteOn' && _m(v.Value).isBefore("${DELETE_ON}")) {
      stdout(v.ResourceId);
    }
  });
}, 'json');
EOM
)

# get snapshots to delete
SNAPSHOTS=$(aws ec2 describe-tags \
  --filters "Name=resource-type,Values=snapshot" \
  | node -e "${SCRIPT}")

# delete them all!
for SNAPSHOT in $SNAPSHOTS;
do
  SNAPSHOTS=aws ec2 delete-snapshot \
    --snapshot-id ${SNAPSHOT}
done
