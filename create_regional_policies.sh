#!/usr/bin/env bash

. env.sh

if [ $# -ne 0 ]; then
    perror "Usage: $0"
fi

# Create regional policies.
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    mkdir -p "$AWS_PWD/$REGION"
    POLICY_NAME="$AWS_APP_NAME-$REGION"
    POLICY_DOCUMENT='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "'${REGION}'"
                }
            }
        }
    ]
}'
    if [ -n "$(policy_exist $POLICY_NAME)" ]; then
        pinfo "Policy for $AWS_APP_NAME on $REGION already exists."
        exit
    fi
    pinfo "Create policy for $AWS_APP_NAME on $REGION."
    $aws iam create-policy --policy-name "$POLICY_NAME" --policy-document "$POLICY_DOCUMENT" > /dev/null
    ) &
done
wait_bg
