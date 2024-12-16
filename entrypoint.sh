#!/bin/bash

# Ensure script exits on error
set -e

# Get inputs from environment variables
AWS_ACCESS_KEY_ID="${INPUT_AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${INPUT_AWS_SECRET_ACCESS_KEY}"
AWS_REGION="${INPUT_AWS_REGION}"
S3_BUCKET_NAME="${INPUT_S3_BUCKET_NAME}"
PROJECT_NAME="${INPUT_PROJECT_NAME}"
ZIP_NAME="${INPUT_ZIP_NAME}"

# Validate required inputs
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_REGION" || -z "$S3_BUCKET_NAME" || -z "$PROJECT_NAME" || -z "$ZIP_NAME" ]]; then
  echo "All inputs must be provided." >&2
  exit 1
fi

# Set AWS credentials for AWS CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="$AWS_REGION"

# Paths
ZIP_PATH="./${ZIP_NAME}"
S3_KEY="${PROJECT_NAME}/${PROJECT_NAME}-${ZIP_NAME}"
BUILD_DIR="./dist"

# Ensure the 'dist' directory exists and is writable
if [[ ! -d "$BUILD_DIR" || ! -w "$BUILD_DIR" ]]; then
  echo "The 'dist' directory does not exist or is not writable by the current user" >&2
  exit 1
fi

# Create the ZIP file from the dist directory
echo "Creating zip file ${ZIP_PATH} from ${BUILD_DIR}..."
zip -r "$ZIP_PATH" "$BUILD_DIR"

# Set liberal permissions for the zip file
chmod 644 "$ZIP_PATH"

# Upload the zip file to S3
S3_KEY="${PROJECT_NAME}/${PROJECT_NAME}-${ZIP_NAME}"
echo "Uploading ${ZIP_PATH} to s3://${S3_BUCKET_NAME}/${S3_KEY}..."
if aws s3 cp "$ZIP_PATH" "s3://${S3_BUCKET_NAME}/${S3_KEY}"; then
  echo "Successfully uploaded ${ZIP_NAME} to s3://${S3_BUCKET_NAME}/${S3_KEY}"
else
  echo "Failed to upload ${ZIP_NAME} to S3" >&2
  exit 1
fi
