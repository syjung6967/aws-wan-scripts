#!/usr/bin/env bash

. env.sh

# Create app group.
if [ -n "$(group_exist $AWS_APP_NAME)" ]; then
    pinfo "App group for $AWS_APP_NAME already exists."
else
    pinfo "Create app group for $AWS_APP_NAME."
    $aws iam create-group --group-name $AWS_APP_NAME
    for policy_arn in $AWS_POLICY_ARN; do
        $aws iam attach-group-policy --policy-arn $policy_arn --group-name $AWS_APP_NAME &
    done
fi
wait_bg

# Create regional users and assign them to the app group.
for REGION in ${AWS_AVAIL_REGIONS[@]}; do
    (
    USER_NAME="$AWS_APP_NAME-$REGION"
    #PASSWORD=$USER_NAME-your-secret-key
    POLICY_NAME="$AWS_APP_NAME-$REGION"
    ACCESS_KEY_FILE=$(get_access_key_file $REGION)
    if [ -n "$(user_exist $USER_NAME)" ]; then
        pinfo "Account $USER_NAME already exists."
        exit
    fi
    pinfo "Create regional account for $AWS_APP_NAME on $REGION."
    mkdir -p "$AWS_PWD/$REGION/.aws"
    $aws iam create-user --user-name $USER_NAME 2> /dev/null
    #aws iam create-login-profile --user-name $USER_NAME --password $PASSWORD --no-password-reset-required
    # "aws iam create-access-key" does not have query option.
    pinfo "Export AWS access key for account $USER_NAME."
    $aws iam create-access-key --user-name $USER_NAME > $ACCESS_KEY_FILE
    # {
    #     "AccessKey": {
    #         "UserName": "myapp-ap-northeast-1",
    #         "AccessKeyId": "XXXXXXXXXXXXXXXXXXXX",
    #         "Status": "Active",
    #         "SecretAccessKey": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    #         "CreateDate": "2021-05-31T11:40:03Z"
    #     }
    # }
    ACCESS_KEY_JSON=`cat $ACCESS_KEY_FILE`
    ACCESS_KEY_ID=`jq '.AccessKey["AccessKeyId"]' <<< $ACCESS_KEY_JSON | tr -d \"`
    SECRET_ACCESS_KEY=`jq '.AccessKey["SecretAccessKey"]' <<< $ACCESS_KEY_JSON | tr -d \"`
    STATUS=`jq '.AccessKey["Status"]' <<< $ACCESS_KEY_JSON | tr -d \"`
    echo -e \
    "[profile default]" \
    "\nregion = $REGION" \
    > "$AWS_PWD/$REGION/.aws/config"
    echo -e \
    "[default]" \
    "\naws_access_key_id = $ACCESS_KEY_ID" \
    "\naws_secret_access_key = $SECRET_ACCESS_KEY" \
    > "$AWS_PWD/$REGION/.aws/credentials"
    $aws iam add-user-to-group --user-name $USER_NAME --group-name $AWS_APP_NAME
    $aws iam attach-user-policy --user-name $USER_NAME --policy-arn "arn:aws:iam::$AWS_ACCOUNT_ID:policy/$POLICY_NAME"
    for N_TRY in `seq 1 3`; do
        pinfo "Check AWS access key for account $USER_NAME ($N_TRY/3): $STATUS."
        if [ "$STATUS" == "Active" ]; then break; fi
        STATUS=`$aws iam list-access-keys --user-name $USER_NAME --query "AccessKeyMetadata[0].Status" | tr -d \"`
    done
    ) &
done
wait_bg
