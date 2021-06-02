#!/usr/bin/env bash

. env.sh

if [ $# -ne 0 ]; then
    perror "Usage: $0"
fi

# Check the app group exists.
E_GROUP="$(group_exist $AWS_APP_NAME)"
if [ -z "$E_GROUP" ]; then
    pinfo "App group for $AWS_APP_NAME has already been deleted."
    exit
fi

# Delete regional users.
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    USER_NAME="$AWS_APP_NAME-$REGION"
    POLICY_NAME="$AWS_APP_NAME-$REGION"
    if [ -z "$(user_exist $USER_NAME)" ]; then
        pinfo "Regional account for $AWS_APP_NAME on $REGION has already been deleted."
        exit
    fi
    pinfo "Delete regional account for $AWS_APP_NAME on $REGION."
    #aws iam delete-login-profile --user-name $USER_NAME
    ACCESS_KEY_ID=$(get_access_key_id $USER_NAME)
    if [ "$ACCESS_KEY_ID" != "null" ]; then
        $aws iam delete-access-key --user-name $USER_NAME --access-key-id $ACCESS_KEY_ID
    fi
    POLICY_ARN=`$aws iam list-attached-user-policies --output text --user-name $USER_NAME --query "AttachedPolicies[].PolicyArn | [0]"`
    if [ "$POLICY_ARN" != "null" ]; then
        $aws iam detach-user-policy --user-name $USER_NAME --policy-arn $POLICY_ARN
    fi
    $aws iam remove-user-from-group --user-name $USER_NAME --group-name $AWS_APP_NAME
    $aws iam delete-user --user-name $USER_NAME
    ) &
done
wait_bg

# Delete app group.
pinfo "Delete app group for $AWS_APP_NAME."
$aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess --group-name $AWS_APP_NAME
$aws iam delete-group --group-name $AWS_APP_NAME
