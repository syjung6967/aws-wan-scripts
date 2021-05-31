#!/usr/bin/env bash

. env.sh

if [ $# -le 0 ]; then
    perror "Usage: $0 ec2 ..."
fi

# Execute input command on each region.
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    STDOUT_DIR="$AWS_PWD/results"
    STDOUT_FILE="$STDOUT_DIR/$REGION.stdout"
    USER_NAME="$AWS_APP_NAME-$REGION"
    ACCESS_KEY_FILE=$(get_access_key_file $REGION)
    mkdir -p $STDOUT_DIR && touch $STDOUT_FILE
    echo -e "\n$(date)\n$@" >> $STDOUT_FILE
    docker run --rm -v "$(get_config_dir $REGION):/root/.aws" amazon/aws-cli $@ | tee -a $STDOUT_FILE
    ) &
done
wait_bg
