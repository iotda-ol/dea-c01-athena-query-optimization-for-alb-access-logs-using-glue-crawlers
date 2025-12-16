#!/bin/bash

# Script to upload sample ALB logs to S3 with proper partitioning structure
# Usage: ./upload-sample-logs.sh <bucket-name>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <s3-bucket-name>"
    echo "Example: $0 athena-alb-logs-alb-logs-abc123"
    exit 1
fi

BUCKET_NAME=$1
BASE_PATH="alb-logs/AWSLogs/123456789012/elasticloadbalancing/us-east-1"

# Create date-based partition structure for today
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)

S3_PATH="s3://${BUCKET_NAME}/${BASE_PATH}/${YEAR}/${MONTH}/${DAY}/"

echo "Uploading sample logs to: ${S3_PATH}"

# Upload the sample log file
aws s3 cp examples/sample-logs/sample-alb-log.log "${S3_PATH}123456789012_elasticloadbalancing_us-east-1_app.my-loadbalancer.50dc6c495c0c9188_${YEAR}${MONTH}${DAY}T1015Z_52.78.12.34_random123.log"

echo "Sample logs uploaded successfully!"
echo ""
echo "Next steps:"
echo "1. Run the Glue Crawler to detect the schema and partitions:"
echo "   aws glue start-crawler --name <crawler-name>"
echo ""
echo "2. Check crawler status:"
echo "   aws glue get-crawler --name <crawler-name>"
echo ""
echo "3. Once crawler completes, query the data in Athena!"
