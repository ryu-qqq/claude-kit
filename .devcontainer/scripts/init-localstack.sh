#!/bin/bash

# LocalStack Initialization Script
# Creates basic AWS resources for development

set -e

echo "🚀 Initializing LocalStack AWS resources..."

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=ap-northeast-2
export AWS_ENDPOINT_URL=http://localhost:4566

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack to be ready..."
timeout 60 bash -c 'until curl -s http://localhost:4566/_localstack/health | grep -qE "\"s3\": \"(available|running)\""; do echo "Waiting..."; sleep 2; done'

echo "✅ LocalStack is ready!"

# Create S3 buckets
echo "📦 Creating S3 buckets..."
aws s3 mb s3://dev-app-bucket --endpoint-url=http://localhost:4566
aws s3 mb s3://dev-uploads --endpoint-url=http://localhost:4566
aws s3 mb s3://dev-backups --endpoint-url=http://localhost:4566

# Create DynamoDB tables
echo "🗃️ Creating DynamoDB tables..."
aws dynamodb create-table \
    --table-name Users \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --endpoint-url=http://localhost:4566

aws dynamodb create-table \
    --table-name Products \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
        AttributeName=category,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --global-secondary-indexes \
        IndexName=CategoryIndex,KeySchema=[{AttributeName=category,KeyType=HASH}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5} \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --endpoint-url=http://localhost:4566

# Create SQS queues
echo "📬 Creating SQS queues..."
aws sqs create-queue \
    --queue-name dev-notifications \
    --endpoint-url=http://localhost:4566

aws sqs create-queue \
    --queue-name dev-tasks-dlq \
    --endpoint-url=http://localhost:4566

aws sqs create-queue \
    --queue-name dev-tasks \
    --attributes VisibilityTimeoutSeconds=300,RedrivePolicy='{"deadLetterTargetArn":"arn:aws:sqs:ap-northeast-2:000000000000:dev-tasks-dlq","maxReceiveCount":3}' \
    --endpoint-url=http://localhost:4566

# Create SNS topics
echo "📢 Creating SNS topics..."
aws sns create-topic \
    --name dev-alerts \
    --endpoint-url=http://localhost:4566

# Create Secrets Manager secrets
echo "🔐 Creating Secrets Manager secrets..."
aws secretsmanager create-secret \
    --name dev/database/credentials \
    --secret-string '{"username":"devuser","password":"devpass","host":"mysql","port":"3306","database":"devdb"}' \
    --endpoint-url=http://localhost:4566

aws secretsmanager create-secret \
    --name dev/api/keys \
    --secret-string '{"openai_api_key":"sk-test-key","jwt_secret":"dev-jwt-secret-key"}' \
    --endpoint-url=http://localhost:4566

# Create CloudWatch Log Groups
echo "📊 Creating CloudWatch Log Groups..."
aws logs create-log-group \
    --log-group-name /aws/lambda/dev-functions \
    --endpoint-url=http://localhost:4566

aws logs create-log-group \
    --log-group-name /dev/application \
    --endpoint-url=http://localhost:4566

# Create SSM parameters
echo "⚙️ Creating SSM parameters..."
aws ssm put-parameter \
    --name "/dev/config/app-name" \
    --value "Claude Dev App" \
    --type "String" \
    --endpoint-url=http://localhost:4566

aws ssm put-parameter \
    --name "/dev/config/environment" \
    --value "development" \
    --type "String" \
    --endpoint-url=http://localhost:4566

aws ssm put-parameter \
    --name "/dev/config/debug-mode" \
    --value "true" \
    --type "String" \
    --endpoint-url=http://localhost:4566

echo ""
echo "✅ LocalStack initialization complete!"
echo ""
echo "📋 Created resources:"
echo "   🪣 S3 Buckets: dev-app-bucket, dev-uploads, dev-backups"
echo "   🗃️ DynamoDB Tables: Users, Products"
echo "   📬 SQS Queues: dev-notifications, dev-tasks (with DLQ)"
echo "   📢 SNS Topics: dev-alerts"
echo "   🔐 Secrets: dev/database/credentials, dev/api/keys"
echo "   📊 Log Groups: /aws/lambda/dev-functions, /dev/application"
echo "   ⚙️ SSM Parameters: /dev/config/* (3 parameters)"
echo ""
echo "🔗 Access LocalStack:"
echo "   Dashboard: http://localhost:4566/_localstack/resources"
echo "   Health: http://localhost:4566/_localstack/health"
echo ""
echo "💡 Usage examples:"
echo "   aws s3 ls --endpoint-url=http://localhost:4566"
echo "   aws dynamodb list-tables --endpoint-url=http://localhost:4566"
echo "   aws sqs list-queues --endpoint-url=http://localhost:4566"