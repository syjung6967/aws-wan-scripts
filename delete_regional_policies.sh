#!/usr/bin/env bash

. env.sh

if [ $# -ne 0 ]; then
    perror "Usage: $0"
fi

# Delete regional policies.
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    POLICY_NAME="$AWS_APP_NAME-$REGION"
    if [ -z "$(policy_exist $POLICY_NAME)" ]; then
        pinfo "Policy for $AWS_APP_NAME on $REGION has already been deleted."
        exit
    fi
    pinfo "Delete policy for $AWS_APP_NAME on $REGION."
    $aws iam delete-policy --policy-arn "arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME"
    ) &
done
wait_bg
