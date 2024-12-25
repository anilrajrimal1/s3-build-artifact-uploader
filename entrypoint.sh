#!/bin/bash

set -e

# Get inputs from environment variables
AWS_ACCESS_KEY_ID="${INPUT_AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${INPUT_AWS_SECRET_ACCESS_KEY}"
AWS_REGION="${INPUT_AWS_REGION}"
S3_BUCKET_NAME="${INPUT_S3_BUCKET_NAME}"
PROJECT_NAME="${INPUT_PROJECT_NAME}"
ZIP_NAME="${INPUT_ZIP_NAME}"

# Ensure all inputs are provided
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_REGION" || -z "$S3_BUCKET_NAME" || -z "$PROJECT_NAME" || -z "$ZIP_NAME" ]]; then
    echo "Error: All inputs (AWS credentials, region, bucket name, project name, zip name) must be provided."
    exit 1
fi

# Create a zip file from the 'dist' directory
BUILD_DIR="./dist"
ZIP_PATH="./${ZIP_NAME}"

if [[ ! -d "$BUILD_DIR" ]]; then
    echo "Error: Build directory '$BUILD_DIR' does not exist."
    exit 1
fi

echo "Creating zip file..."
zip -r "$ZIP_PATH" "$BUILD_DIR"

# Upload the zip file to S3
echo "Uploading zip file to S3..."
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION

S3_KEY="${PROJECT_NAME}/${PROJECT_NAME}-${ZIP_NAME}"

aws s3 cp "$ZIP_PATH" "s3://${S3_BUCKET_NAME}/${S3_KEY}"

echo "Successfully uploaded ${ZIP_NAME} to s3://${S3_BUCKET_NAME}/${S3_KEY}"
