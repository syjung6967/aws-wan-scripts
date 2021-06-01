#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-key-pairs.sh)
NUM_KEYS=`jq length <<< $text`
if [ "$NUM_KEYS" -eq 0 ]; then
    pinfo "There are no keys on $AWS_REGION!"
    exit
fi

KEY_PAIR_ID_LIST=`jq '.[]["KeyPairId"]' <<< $text | tr -d \"`
KEY_PAIR_ID_LIST=`echo $KEY_PAIR_ID_LIST`
for key_id in $KEY_PAIR_ID_LIST; do
    pinfo "Delete $key_id on $AWS_REGION."
    # Output is None
    $AWS_REGION_CLI ec2 delete-key-pair --key-pair-id $key_id
done
