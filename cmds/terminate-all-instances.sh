#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-instances.sh)
if [ "$text" == "[]" ]; then
    pinfo "There are no instances on $AWS_REGION!"
    exit
fi
INSTANCE_ID_LIST=$(JSON '.[]["InstanceId"]' "$text")
ZONE_LIST=$(JSON '.[]["Placement"]["AvailabilityZone"]' "$text")
pinfo "Terminate Instances: $INSTANCE_ID_LIST ($ZONE_LIST)"
pinfo "WARNING: Mount points are disconnected."
$AWS_REGION_CLI ec2 terminate-instances --instance-ids $INSTANCE_ID_LIST \
| tee -a $STDOUT_FILE
