#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

KEY_NAME="$AWS_APP_NAME-$AWS_REGION"
pinfo "Run $AWS_INSTANCE_TYPE instance using key $KEY_NAME."

$AWS_REGION_CLI ec2 run-instances \
--tag-specifications "ResourceType=instance,Tags=[{Key=$AWS_APP_NAME,Value=True}]" \
--image-id "$(get_recent_aws_image_id $AWS_REGION)" \
--instance-market-options "$AWS_INSTANCE_MARKET_OPTIONS" \
--instance-type "$AWS_INSTANCE_TYPE" \
--key-name "$KEY_NAME" \
--block-device-mappings "$AWS_BLOCK_DEVICE_MAPPINGS" \
--user-data "$AWS_USER_DATA" \
| tee -a $STDOUT_FILE
