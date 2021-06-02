#!/usr/bin/env bash

. env.sh

if [ $# -ne 0 ]; then
    perror "Usage: $0"
fi

# Export only running instances info on each region.
pinfo "Create temporary files for retrieving instance list."
TMP_DIR=`mktemp -d`
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    AWS_REGION_CLI="docker run --rm -v "$(get_config_dir $REGION):/root/.aws" amazon/aws-cli"
    TMP_FILE="$TMP_DIR/$REGION"
    $AWS_REGION_CLI ec2 describe-instances \
    --output text \
    --filters $APP_FILTER "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].[Placement.AvailabilityZone,InstanceId,PrivateIpAddress,PublicIpAddress]" \
    > $TMP_FILE
    pinfo "Found $(wc -l $TMP_FILE | cut -d' ' -f1) active instance(s) on $REGION"
    cat $TMP_FILE
    ) &
done
wait_bg

IP_LIST_FILE="$AWS_PWD/ip_list.txt"
pinfo "Overwrite IP list file $IP_LIST_FILE."
rm -f $IP_LIST_FILE
echo -e "Availability zone\tInstance ID\tPrivate IP\tPublic IP\tEntry point" > "$IP_LIST_FILE"
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    awk '
    { printf "%s\t%s\t%s\t%s\tssh -i '"$AWS_PWD/keys/$REGION.pem $AWS_INSTANCE_USER_NAME@"'%s\n", $1, $2, $3, $4, $4 }
    ' "$TMP_DIR/$REGION" >> "$IP_LIST_FILE"
done

pinfo "Remove temporary files."
rm -r "$TMP_DIR"
