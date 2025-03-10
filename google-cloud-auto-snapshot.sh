#!/bin/bash

if [ -z "${DAYS_RETENTION}" ]; then
  # Default to 60 days
  DAYS_RETENTION=60
fi

# Author: Alan Fuller, Fullworks
# loop through all disks within this project  and create a snapshot
gcloud compute disks list --filter="labels.backup=true" --format='value(name,zone)'| while read -r DISK_NAME ZONE; do
  gcloud compute snapshots create autogcs-"${DISK_NAME:0:31}"-"$(date '+%Y-%m-%d-%s')" --source-disk="${DISK_NAME}" --source-disk-zone="${ZONE}" --snapshot-type="${SNAPSHOT_TYPE:-ARCHIVE}"
done
#
# snapshots are incremental and dont need to be deleted, deleting snapshots will merge snapshots, so deleting doesn't loose anything
# having too many snapshots is unwiedly so this script deletes them after n days
#
if [[ $(uname) == "Linux" ]]; then
  from_date=$(date -d "-${DAYS_RETENTION} days" "+%Y-%m-%d")
else
  from_date=$(date -v -${DAYS_RETENTION}d "+%Y-%m-%d")
fi
gcloud compute snapshots list --filter="creationTimestamp<${from_date} AND name~'autogcs.*'" --uri | while read -r SNAPSHOT_URI; do
   gcloud compute snapshots delete "${SNAPSHOT_URI}" --quiet
done
#
