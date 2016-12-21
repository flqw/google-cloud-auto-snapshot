#!/bin/bash
# loop through all disks within this project  and create a snapshot
gcloud compute disks list | tail -n +2 | while read DISK_NAME ZONE c3 c4; do
  gcloud compute disks snapshot $DISK_NAME --snapshot-names autogcs-$DISK_NAME-$(date "+%Y-%m-%d-%s") --zone $ZONE
done
#
# snapshots are incremental and dont need to be deleted, deleting snapshots will merge snapshots, so deleting doesn't loose anything
# having too many snapshots is unwiedly so this script deletes them after 60 days
#
gcloud compute snapshots list --filter="creationTimestamp<$(date -d "-60 days" "+%Y-%m-%d")" --regexp "(autogcs.*)" --uri | while read SNAPSH
OT_URI; do
   gcloud compute snapshots delete $SNAPSHOT_URI
done
# 