#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

$AWS_REGION_CLI ec2 describe-key-pairs \
--filter $APP_FILTER \
--query "KeyPairs[]" \
| tee -a $STDOUT_FILE
