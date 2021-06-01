#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-key-pairs.sh)
KEY_NAME="$AWS_APP_NAME-$AWS_REGION"
NUM_KEYS=`jq length <<< $text`
if [ $NUM_KEYS -gt 0 ]; then
    pinfo "Key $KEY_NAME already exists!"
    exit
fi

$AWS_REGION_CLI ec2 create-key-pair \
--tag-specifications "ResourceType=key-pair,Tags=[{Key=$AWS_APP_NAME,Value=True}]" \
--key-name "$KEY_NAME" \
| tee -a $STDOUT_FILE
