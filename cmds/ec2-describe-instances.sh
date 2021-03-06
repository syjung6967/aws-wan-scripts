#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

$AWS_REGION_CLI ec2 describe-instances \
--filters $APP_FILTER $INSTANCE_FILTER \
--query Reservations[].Instances[] \
| tee -a $STDOUT_FILE
