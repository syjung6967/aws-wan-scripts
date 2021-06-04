#!/usr/bin/env bash

. env.sh

if [ $# -ne 0 ]; then
    perror "Usage: $0"
fi

./export_connection_info.sh

pinfo "
Mount filesystems for current running instances.
"

IP_LIST_FILE="$AWS_PWD/ip_list.txt"
n=0 # Current line number.
while read -r text; do
    (
    if [ $n -gt 0 ]; then # Ignore header.
        # "Region\tAvailability zone\tInstance ID\tPrivate IP\tPublic IP\tEntry point"
        REGION=`echo $text | cut -d' ' -f1`
        AZ=`echo $text | cut -d' ' -f2`
        IP=`echo $text | cut -d' ' -f5`
        INSTANCE_MOUNT_DIR="$AWS_PWD/$REGION/$AZ/$IP"
        mkdir -p $INSTANCE_MOUNT_DIR
        fusermount -uq $INSTANCE_MOUNT_DIR # Unmount if mounted.
        sshfs -o "IdentityFile=$AWS_PWD/keys/$REGION.pem" \
              -o "StrictHostKeyChecking=accept-new" \
              "$AWS_INSTANCE_USER_NAME@$IP:" $INSTANCE_MOUNT_DIR
    fi
    ) &
    n=$((n + 1))
done < $IP_LIST_FILE
wait_bg

pinfo "Mount information:"
echo -e "Filesystem\tSize\tUsed\tAvail\tUse%\tMounted on"
df -h --output="source,size,used,avail,pcent,target" | grep "$AWS_PWD"
