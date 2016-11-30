#!/bin/sh

set -x
set -e

# TODO param for: vpc-config SubnetIds="subnet-7aee3012"

# IAM_ROLE_CRONUSER=$(aws iam get-user --user-name lambda-cronuser \
#  | node -e "require('curt').stdin_get('User.Arn')")

IAM_ROLE_CRONUSER=$(aws iam get-role --role-name role-lambda-cronuser \
  --query 'Role.Arn' --output text)

SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --group-names lambda \
  --query 'SecurityGroups[0].GroupId' --output text)

COUNTER=0

# pure cron functions (no ec2 interaction)

for FUNCTION in "create-snapshots" "delete-snapshots";
do
  COUNTER=$(($COUNTER + 1))
  ZIP="${FUNCTION}.zip"

  zip -9 -q -r ${ZIP} "${FUNCTION}.js" package.json node_modules

  ## --code S3Bucket="${AWS_CLIENT_ID}-aws-lambda,S3Key=./${ZIP}" \
  # http://docs.aws.amazon.com/cli/latest/reference/lambda/index.html#cli-aws-lambda

  aws lambda delete-function --function-name "${FUNCTION}" || echo "Ignore error"

  FUNCTION_ARN=$(aws lambda create-function --function-name "${FUNCTION}" --runtime nodejs4.3 \
    --role "${IAM_ROLE_CRONUSER}" --handler "${FUNCTION}.handler" \
    --zip-file "fileb://${ZIP}" \
    --description ${FUNCTION} \
    --query 'FunctionArn' --output text)

  echo "Function ARN: ${FUNCTION_ARN}"

  RULE_ARN=$(aws events list-rules \
  | node -e "require('curt').stdin((j) => { stdout(_(j.Rules).find({Name:'daily'}).Arn) }, 'json')")

  echo "Rule ARN: ${RULE_ARN}"

  aws events put-targets \
    --rule daily \
    --targets "{\"Id\" : \"1\", \"Arn\": \"${FUNCTION_ARN}\", \"Input\": \"{\\\"rule-name\\\": \\\"daily\\\"}\"}"

  if [ "create-snapshots" == "${FUNCTION}" ]; then
    aws events put-targets \
      --rule daily \
      --targets "{\"Id\" : \"1\", \"Arn\": \"${FUNCTION_ARN}\", \"Input\": \"{\\\"rule-name\\\": \\\"weekly\\\"}\"}"
  fi

  aws lambda add-permission \
      --function-name "${FUNCTION}" \
      --action 'lambda:InvokeFunction' \
      --principal events.amazonaws.com \
      --statement-id ${COUNTER} \
      --source-arn ${RULE_ARN} \
      --query Statement.Effect --output text

  rm ${ZIP}
done


# test
# aws lambda invoke --function-name delete-snapshots --payload '{"hello":"world"}'

# VPC functions

for FUNCTION in "ssh-test"
do
  COUNTER=$(($COUNTER + 1))
  ZIP="${FUNCTION}.zip"

  zip -9 -q -r ${ZIP} "${FUNCTION}.js" package.json node_modules

  aws lambda delete-function --function-name "${FUNCTION}" || echo "Ignore error"

  FUNCTION_ARN=$(aws lambda create-function --function-name "${FUNCTION}" --runtime nodejs4.3 \
    --role "${IAM_ROLE_CRONUSER}" --handler "${FUNCTION}.handler" \
    --zip-file "fileb://${ZIP}" \
    --description ${FUNCTION} \
    --vpc-config SubnetIds="subnet-7aee3012",SecurityGroupIds="${SECURITY_GROUP_ID}" \
    --timeout 60 \
    --query 'FunctionArn' --output text)

  echo "Function ARN: ${FUNCTION_ARN}"

  rm ${ZIP}
done
