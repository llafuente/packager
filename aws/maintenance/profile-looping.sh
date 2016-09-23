#!/bin/sh

# loop your profile and do... what you write!

for PROFILE in `ack profile ~/.aws/config | sed 's/^.* \(.*\)\]/\1/'`;
do
  echo "Using profile: ${PROFILE}"
  # mad science here plz
done
