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

# Policy.
export AWS_POLICY_ARN="
arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess
"

# TODO: per instance specification.
export AWS_INSTANCE_MARKET_OPTIONS="${AWS_INSTANCE_MARKET_OPTIONS:-MarketType=spot}"
export AWS_INSTANCE_TYPE="${AWS_INSTANCE_TYPE:-m5.2xlarge}" #"t3.nano"
export AWS_INSTANCE_AMI="${AWS_INSTANCE_AMI:-Ubuntu 18.04}"
# Check user name for instance with the AMI provider.
case "$AWS_INSTANCE_AMI" in
    "Ubuntu 16.04" | "Ubuntu 18.04" | "Ubuntu 20.04")
        export AWS_INSTANCE_USER_NAME="ubuntu" ;;
    "Amazon Linux 2")
        export AWS_INSTANCE_USER_NAME="ec2-user" ;;
    "Alpine Linux")
        export AWS_INSTANCE_USER_NAME="alpine" ;;
    *)
        perror "Check \$AWS_INSTANCE_AMI (current value: $AWS_INSTANCE_AMI)" ;;
esac
export AWS_BLOCK_DEVICE_MAPPINGS="DeviceName=/dev/xvda,Ebs={VolumeSize=8,VolumeType=gp3}"
export AWS_USER_DATA=""

# Check app filter turned on.
export DISABLE_APP_FILTER="${DISABLE_APP_FILTER:-}"
if [ -z "$DISABLE_APP_FILTER" ]; then
    export APP_FILTER="Name=tag-key,Values=$AWS_APP_NAME"
else
    export APP_FILTER=""
fi
# Query instances which state is not terminated.
export INSTANCE_FILTER="Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped"

# Check available regions:
#   aws ec2 describe-regions --query '["Regions"][]["RegionName"][]'
export AWS_AVAIL_REGIONS=(
#   'eu-north-1' # Europe (Stockholm)
#   'ap-south-1' # Asia Pacific (Mumbai)
#   'eu-west-3' # Europe (Paris)
#   'eu-west-2' # Europe (London)
#   'eu-west-1' # Europe (Ireland)
#   'ap-northeast-3' # Asia Pacific (Osaka-Local)
#   'ap-northeast-2' # Asia Pacific (Seoul)
#   'ap-northeast-1' # Asia Pacific (Tokyo)
#   'sa-east-1' # South America (São Paulo)
#   'ca-central-1' # Canada (Central)
#   'ap-southeast-1' # Asia Pacific (Singapore)
#   'ap-southeast-2' # Asia Pacific (Sydney)
#   'eu-central-1' # Europe (Frankfurt)
    'us-east-1' # US East (N. Virginia)
    'us-east-2' # US East (Ohio)
    'us-west-1' # US West (N. California)
#   'us-west-2' # US West (Oregon)
)

# Find the latest AMIs.
get_recent_aws_image_id() { # Image ID is different among regions.
    local AMI_FILTER
    local AMI_OWNER
    case "$AWS_INSTANCE_AMI" in
        "Ubuntu 16.04")
            AMI_OWNER="099720109477"
            AMI_FILTER="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-????????" ;;
        "Ubuntu 18.04")
            AMI_OWNER="099720109477"
            AMI_FILTER="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-????????" ;;
        "Ubuntu 20.04")
            AMI_OWNER="099720109477"
            AMI_FILTER="Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-????????" ;;
        "Amazon Linux 2")
            AMI_OWNER="amazon"
            AMI_FILTER="Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2" ;;
        "Alpine Linux")
            AMI_OWNER="538276064493"
            AMI_FILTER="Name=name,Values=alpine-ami-3.??.?-x86_64-r?" ;;
    esac
    local ID=`$aws ec2 describe-images --output text \
    --region $1 \
    --owners $AMI_OWNER \
    --query "max_by(Images[], &CreationDate).ImageId" \
    --filters $AMI_FILTER "Name=state,Values=available"`
    echo "$ID"
}

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

get_config_dir() {
    echo "$AWS_PWD/$1/.aws"
}

if [ -z "$AWS_ACCOUNT_ID" ]; then
    perror "Check your 12-digit AWS account ID (AWS_ACCOUNT_ID)!"
fi

if [ -z "$AWS_PROFILE_NAME" ]; then
    perror "Check your AWS profile name (AWS_PROFILE_NAME)!"
fi
