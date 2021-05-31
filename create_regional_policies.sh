#!/usr/bin/env bash

. env.sh

# Create regional policies.
mkdir -p "$AWS_PWD/policy"
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    POLICY_FILE="$AWS_PWD/policy/$REGION.json"
    POLICY_NAME="$AWS_APP_NAME-$REGION"
    if [ -f $POLICY_FILE ]; then
        pinfo "Policy spec for $AWS_APP_NAME on $REGION already exists."
    else
        pinfo "Create policy spec for $AWS_APP_NAME on $REGION."
        cat << EOF > $POLICY_FILE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "${REGION}"
                }
            }
        }
    ]
}
EOF
    fi

    if [ -n "$(policy_exist $POLICY_NAME)" ]; then
        pinfo "Policy for $AWS_APP_NAME on $REGION already exists."
        exit
    fi
    pinfo "Create policy for $AWS_APP_NAME on $REGION."
    aws iam create-policy --policy-name $POLICY_NAME --policy-document "file://$POLICY_FILE" 2> /dev/null
    ) &
done
wait_bg
