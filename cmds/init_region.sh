#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-key-pairs.sh)
NUM_KEYS=`jq length <<< $text`
if [ "$NUM_KEYS" -eq 0 ]; then
    pinfo "There is no key on $AWS_REGION!"
    cmds/ec2-create-key-pair.sh
else
    pinfo "Key on $AWS_REGION already exists."
fi

# Create default VPC and subnet if not exist.
text=`$AWS_REGION_CLI ec2 describe-vpcs --query "Vpcs[]" --filters "Name=isDefault,Values=true"`
if [ "$text" == "[]" ]; then
    pinfo "Default VPC on $AWS_REGION does not exist; Create the default VPC."
    $AWS_REGION_CLI ec2 create-default-vpc | tee -a $STDOUT_FILE
else
    pinfo "Default VPC on $AWS_REGION already exists."
fi
text=`$AWS_REGION_CLI ec2 describe-subnets --query "Subnets[]" --filters "Name=default-for-az,Values=true"`
if [ "$text" == "[]" ]; then
    pinfo "Default Subnets on $AWS_REGION do not exist; Create the default subnets."
    text=`$AWS_REGION_CLI ec2 describe-availability-zones --query "AvailabilityZones[].ZoneName"`
    # Create subnets sequentially to prevent from reaching max retries 2.
    for zone in `jq '.[]' <<< $text | tr -d \"`; do
        $AWS_REGION_CLI ec2 create-default-subnet --availability-zone "$zone" | tee -a $STDOUT_FILE
    done
else
    pinfo "Default Subnets on $AWS_REGION already exist."
fi
