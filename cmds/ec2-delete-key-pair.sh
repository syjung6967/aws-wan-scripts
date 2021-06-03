#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-key-pairs.sh)
if [ "$text" == "[]" ]; then
    pinfo "There are no keys on $AWS_REGION!"
    exit
fi

for key_id in $(JSON '.[]["KeyPairId"]' "$text"); do
    pinfo "Delete $key_id on $AWS_REGION."
    # Output is None
    $AWS_REGION_CLI ec2 delete-key-pair --key-pair-id $key_id
done
