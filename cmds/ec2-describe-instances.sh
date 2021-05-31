#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

$AWS_REGION_CLI ec2 describe-instances \
$APP_FILTER \
--query Reservations[].Instances[].[Placement.AvailabilityZone,InstanceId,PublicIpAddress,State.Name] \
| tee -a $STDOUT_FILE
