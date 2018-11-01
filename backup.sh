#!/bin/sh


ENVIRONMENT=${ENVIRONMENT:-dev}
REGION=${AWS_REGION:-us-east-1}

if [[ -z "${IDENTIFIER}" ]]; then
  echo "Missing environment variable IDENTIFIER"
  exit 1
fi

echo env: ${ENVIRONMENT}
echo identifier: ${IDENTIFIER}

DATABASE_HOST=${DATABASE_HOST:-`aws ssm get-parameter --region $REGION --name "/$ENVIRONMENT/cron/backup/$IDENTIFIER/host" --with-decrypt --query "Parameter.Value" --output text`}

if [[ -z "${DATABASE_HOST}" ]]; then
  echo "Missing environment variable DATABASE_HOST"
  exit 1
fi

DATABASE_NAME=${DATABASE_NAME:-`aws ssm get-parameter --region $REGION --name "/$ENVIRONMENT/cron/backup/$IDENTIFIER/name" --with-decrypt --query "Parameter.Value" --output text`}

if [[ -z "${DATABASE_NAME}" ]]; then
  echo "Missing environment variable DATABASE_NAME"
  exit 1
fi

DATABASE_USER=${DATABASE_USER:-`aws ssm get-parameter --region $REGION --name "/$ENVIRONMENT/cron/backup/$IDENTIFIER/user" --with-decrypt --query "Parameter.Value" --output text`}

if [[ -z "${DATABASE_USER}" ]]; then
  echo "Missing environment variable DATABASE_USER"
  exit 1
fi

DATABASE_PASSWORD=${DATABASE_PASSWORD:-`aws ssm get-parameter --region $REGION --name "/$ENVIRONMENT/cron/backup/$IDENTIFIER/password" --with-decrypt --query "Parameter.Value" --output text`}

if [[ -z "${DATABASE_PASSWORD}" ]]; then
  echo "Missing environment variable DATABASE_PASSWORD"
  exit 1
fi

S3_BUCKET=${S3_BUCKET:-`aws ssm get-parameter --region $REGION --name "/$ENVIRONMENT/cron/backup/$IDENTIFIER/bucket" --with-decrypt --query "Parameter.Value" --output text`}

if [[ -z "${S3_BUCKET}" ]]; then
  echo "Missing environment variable S3_BUCKET"
  exit 1
fi

DATE=$(date -I)
TARGET=s3://${S3_BUCKET}/${IDENTIFIER}-${DATE}.sql.gz

echo Backing up ${DATABASE_HOST}/${DATABASE_NAME} to ${TARGET}

export PGPASSWORD=${DATABASE_PASSWORD}
pg_dump -Z 9 -v -h ${DATABASE_HOST} -U ${DATABASE_USER} -d ${DATABASE_NAME} | aws s3 cp --storage-class STANDARD_IA --sse aws:kms - ${TARGET}
rc=$?
export PGPASSWORD=

if [[ $rc != 0 ]]; then exit $rc; fi

echo Done