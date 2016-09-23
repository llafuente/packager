#!/bin/sh

set -x
set -e

if [ -z ${AWS_CLIENT_ID} ]; then
  echo "export credentials first!"
  echo "KO"
  exit 1
fi

# AWS_IAM_ROLE=$(aws iam get-user --user-name lambda-cronuser \
#  | node -e "require('curt').stdin_get('User.Arn')")

AWS_IAM_ROLE=$(aws iam get-role --role-name role-lambda-cronuser \
  --query 'Role.Arn' --output text)


COUNTER=0
for FUNCTION in "create-snapshots" "delete-snapshots";
do
  COUNTER=$(($COUNTER + 1))
  ZIP="${FUNCTION}.zip"

  zip -9 -q -r ${ZIP} "${FUNCTION}.js" package.json node_modules

  ## --code S3Bucket="${AWS_CLIENT_ID}-aws-lambda,S3Key=./${ZIP}" \
  # http://docs.aws.amazon.com/cli/latest/reference/lambda/index.html#cli-aws-lambda

  aws lambda delete-function --function-name "${FUNCTION}" || echo "Ignore error"

  FUNCTION_ARN=$(aws lambda create-function --function-name "${FUNCTION}" --runtime nodejs4.3 \
    --role "${AWS_IAM_ROLE}" --handler "${FUNCTION}.handler" \
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
    #--targets "{\"Id\" : \"1\", \"Arn\": \"${FUNCTION_ARN}\", \"Input\": {\"rule\": \"daily\"}}"

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
