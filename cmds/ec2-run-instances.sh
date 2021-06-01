#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-key-pairs.sh)
NUM_KEYS=`jq length <<< $text`
if [ "$NUM_KEYS" -eq 0 ]; then
    pinfo "There are no keys on $AWS_REGION!"
    pinfo "Generate key on $AWS_REGION."
    text=$(cmds/ec2-create-key-pair.sh)
    mkdir -p "$AWS_PWD/keys"
    echo $text > "$AWS_PWD/keys/$AWS_REGION.key.json"
fi

pinfo "Use key $AWS_REGION."

$AWS_REGION_CLI ec2 run-instances \
--tag-specifications "ResourceType=instance,Tags=[{Key=$AWS_APP_NAME,Value=True}]" \
--image-id "$(get_recent_aws_image_id $AWS_REGION)" \
--instance-market-options "$AWS_INSTANCE_MARKET_OPTIONS" \
--instance-type "$AWS_INSTANCE_TYPE" \
--key-name "$AWS_APP_NAME-$AWS_REGION" \
--block-device-mappings "$AWS_BLOCK_DEVICE_MAPPINGS" \
--user-data "$AWS_USER_DATA" \
| tee -a $STDOUT_FILE
