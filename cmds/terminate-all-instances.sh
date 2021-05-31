#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-instances.sh)
NUM_INSTANCES=`jq length <<< $text`
if [ $NUM_INSTANCES -eq 0 ]; then
    pinfo "There are no instances on $AWS_REGION!"
    exit
fi
INSTANCE_ID_LIST=`jq '.[]["InstanceId"]' <<< $text | tr -d \"`
INSTANCE_ID_LIST=`echo $INSTANCE_ID_LIST`
ZONE_LIST=`jq '.[]["Placement"]["AvailabilityZone"]' <<< $text | tr -d \"`
ZONE_LIST=`echo $ZONE_LIST`
pinfo "Terminate Instances: $INSTANCE_ID_LIST ($ZONE_LIST)"
$AWS_REGION_CLI ec2 terminate-instances --instance-ids $INSTANCE_ID_LIST \
| tee -a $STDOUT_FILE
#--query Reservations[].Instances[].[Placement.AvailabilityZone,InstanceId,PublicIpAddress,State.Name] \
