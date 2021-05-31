#!/usr/bin/env bash

. util.sh

# Guide.
#https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_cliwpsapi
#https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_manage.html#id_users_deleting_cli
#https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_manage_delete.html

export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}" # It differs to AWS_ACCESS_KEY_ID.
export AWS_PROFILE_NAME="${AWS_PROFILE_NAME:-default}"
export AWS_APP_NAME="${AWS_APP_NAME:-myapp}"
export AWS_PWD="$PWD/resources/$AWS_PROFILE_NAME/$AWS_APP_NAME"
export aws="aws --profile $AWS_PROFILE_NAME"

# Check app filter turned on.
export DISABLE_APP_FILTER="${DISABLE_APP_FILTER:-}"
if [ -z "$DISABLE_APP_FILTER" ]; then
    export APP_FILTER="--filter Name=tag-key,Values=$AWS_APP_NAME"
else
    export APP_FILTER=""
fi

# Check available regions:
#   aws ec2 describe-regions
export AWS_AVAIL_REGIONS=(
    #'us-east-2' # US East (Ohio)
    #'us-east-1' # US East (N. Virginia)
    #'us-west-1' # US West (N. California)
    #'us-west-2' # US West (Oregon)
    #'ap-east-1' # Asia Pacific (Hong Kong)
    #'ap-south-1' # Asia Pacific (Mumbai)
    #'ap-northeast-3' # Asia Pacific (Osaka-Local)
    'ap-northeast-2' # Asia Pacific (Seoul)
    #'ap-southeast-1' # Asia Pacific (Singapore)
    #'ap-southeast-2' # Asia Pacific (Sydney)
    'ap-northeast-1' # Asia Pacific (Tokyo)
    #'ca-central-1' # Canada (Central)
    #'eu-central-1' # Europe (Frankfurt)
    #'eu-west-1' # Europe (Ireland)
    #'eu-west-2' # Europe (London)
    #'eu-west-3' # Europe (Paris)
    #'eu-north-1' # Europe (Stockholm)
    #'me-south-1' # Middle East (Bahrain)
    #'sa-east-1' # South America (São Paulo)
)

group_exist() {
    local E=`$aws iam get-group --group-name $1 --query "Group.GroupName" 2> /dev/null | tr -d \"`
    if [ -n "$E" ]; then echo "yes"; fi
}

user_exist() {
    local E=`$aws iam get-user --user-name $1 --query "User.UserName" 2> /dev/null | tr -d \"`
    if [ -n "$E" ]; then echo "yes"; fi
}

policy_exist() {
    local POLICY_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:policy/$1"
    local E=`$aws iam get-policy --policy-arn $POLICY_ARN --query "Policy.PolicyName" 2> /dev/null | tr -d \"`
    if [ -n "$E" ]; then echo "yes"; fi
}

get_access_key_id() {
    local ID=`$aws iam list-access-keys --user-name $1 --query "AccessKeyMetadata[].AccessKeyId | [0]" | tr -d \"`
    echo "$ID"
}

get_access_key_file() {
    echo "$AWS_PWD/$1/aws-access-key.json"
}

get_config_dir() {
    echo "$AWS_PWD/$1/.aws"
}

if [ -z "$AWS_ACCOUNT_ID" ]; then
    perror "Check your 12-digit AWS account ID (AWS_ACCOUNT_ID)!"
fi

if [ -z "$AWS_PROFILE_NAME" ]; then
    perror "Check your AWS profile name (AWS_PROFILE_NAME)!"
fi
