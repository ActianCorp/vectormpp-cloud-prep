#!/bin/bash
set -xe

CLUSTER_NAME=$1
ACTION=$2
if [ -z "$CLUSTER_NAME" -o -z "$ACTION" ]; then
    echo "Usage: $0 CLUSTER_NAME add_to_trust_policy|delete_from_trust_policy"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text --no-cli-pager | tr -d '[:space:]')

ROLE_NAME="AVSampleDataBucketAssumeRole"
ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/$CLUSTER_NAME-data-plane"
TRUST_POLICY_JSON=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.AssumeRolePolicyDocument' --output json)

aws_principals=$(echo "$TRUST_POLICY_JSON" | jq '.Statement[0].Principal.AWS')
if echo "$aws_principals" | jq -e 'if type == "string" then true else false end' > /dev/null; then
    aws_principals=$(echo "$aws_principals" | jq -r '.')
    # Handle the case where it's a single string
    if [[ $aws_principals == arn:aws:iam* ]]; then
        filtered_principals="\"$aws_principals\""
    else
        filtered_principals=""
    fi
else
    aws_principals=$(echo "$TRUST_POLICY_JSON" | jq -r '.Statement[0].Principal.AWS[]')
    filtered_principals=()
    for principal in $aws_principals; do
        if [[ $principal == arn:aws:iam* ]]; then
            filtered_principals+=("\"$principal\"")
        fi
    done
    filtered_principals=$(printf ", %s" "${filtered_principals[@]}")
    filtered_principals="[${filtered_principals:2}]"
fi
TRUST_POLICY_JSON=$(echo "$TRUST_POLICY_JSON" | jq --argjson principals "$filtered_principals" '.Statement[0].Principal.AWS = $principals')

if echo $TRUST_POLICY_JSON | jq -e ".Statement[].Principal.AWS" | grep -q "$ROLE_ARN"; then
    if [ "$ACTION" = "add_to_trust_policy" ]; then
        echo "Already trusted."
        exit 0
    fi
    UPDATED_TRUST_POLICY=$(echo $TRUST_POLICY_JSON | jq --arg role_arn "$ROLE_ARN" '
      .Statement[].Principal.AWS |= (if type == "array" then map(select(. != $role_arn)) else select(. != $role_arn) end)
    ')
else
    if [ "$ACTION" = "delete_from_trust_policy" ]; then
        echo "Not in trust policy."
        exit 0
    fi
    UPDATED_TRUST_POLICY=$(echo $TRUST_POLICY_JSON | jq --arg role_arn "$ROLE_ARN" '
    .Statement[].Principal.AWS |= (if type == "array" then . + [$role_arn] else [$role_arn, .] end)
    ')
fi
aws iam update-assume-role-policy --role-name $ROLE_NAME --policy-document "$UPDATED_TRUST_POLICY"
