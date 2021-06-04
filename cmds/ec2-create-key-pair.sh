#!/usr/bin/env bash

. env.sh

AWS_REGION_CLI="${AWS_REGION_CLI:-$aws}"
AWS_REGION="${AWS_REGION:-default}"
STDOUT_FILE="${STDOUT_FILE:-/dev/null}"

text=$(cmds/ec2-describe-key-pairs.sh)
KEY_NAME="$AWS_APP_NAME-$AWS_REGION"
if [ "$text" != "[]" ]; then
    pinfo "Key $KEY_NAME already exists!"
    exit
fi

pinfo "Generate key on $AWS_REGION."
mkdir -p "$AWS_PWD/keys"
text=`
$AWS_REGION_CLI ec2 create-key-pair \
--tag-specifications "ResourceType=key-pair,Tags=[{Key=$AWS_APP_NAME,Value=True}]" \
--key-name "$KEY_NAME"
`
PRIVATE_KEY=$(JSON_FORMAT '.["KeyMaterial"]' "$text" | tr -d \")
rm -f "$AWS_PWD/keys/$AWS_REGION.pem"
echo -e $PRIVATE_KEY > "$AWS_PWD/keys/$AWS_REGION.pem"
chmod 400 "$AWS_PWD/keys/$AWS_REGION.pem" # Avoid permission issue.
pinfo $(JSON '.["KeyPairId"]' "$text")
