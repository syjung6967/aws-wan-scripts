#!/usr/bin/env bash

. env.sh

if [ $# -ne 1 ]; then
    perror "Usage: $0 ec2 <cmd_script>"
fi

# Execute input command on each region.
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    export AWS_REGION_CLI="docker run --rm -v "$(get_config_dir $REGION):/root/.aws" amazon/aws-cli"
    export AWS_REGION="$REGION"
    STDOUT_DIR="$AWS_PWD/results"
    export STDOUT_FILE="$STDOUT_DIR/$REGION.stdout"
    mkdir -p $STDOUT_DIR && touch $STDOUT_FILE
    echo -e "\n$(date)\n$@" >> $STDOUT_FILE
    $1
    ) &
done
wait_bg
