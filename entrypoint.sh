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

# Ensure all inputs are provided
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_REGION" || -z "$S3_BUCKET_NAME" || -z "$PROJECT_NAME" || -z "$ZIP_NAME" ]]; then
  echo "All inputs (AWS credentials, region, bucket name, project name, zip name) must be available." >&2
  exit 1
fi

# Get the current user ID and group ID
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

# Ensure the current directory is writable by the current user
ZIP_PATH="./${ZIP_NAME}"
if [[ ! -w $(dirname "$ZIP_PATH") ]]; then
  echo "The directory for ${ZIP_PATH} is not writable by the current user" >&2
  exit 1
fi

# Ensure the 'dist' directory exists and is writable
BUILD_DIR="./dist"
if [[ ! -d "$BUILD_DIR" || ! -w "$BUILD_DIR" ]]; then
  echo "The 'dist' directory does not exist or is not writable by the current user" >&2
  exit 1
fi

echo "Creating zip file ${ZIP_PATH} from ${BUILD_DIR}..."

zip -r "$ZIP_PATH" "$BUILD_DIR"

# Set correct permissions for the zip file and files inside 'dist/'
chmod 644 "$ZIP_PATH"
chown "$CURRENT_UID:$CURRENT_GID" "$ZIP_PATH"

echo "Setting permissions for files in the dist/ directory..."
find "$BUILD_DIR" -type f -exec chmod 644 {} \;
find "$BUILD_DIR" -type f -exec chown "$CURRENT_UID:$CURRENT_GID" {} \;

find "$BUILD_DIR" -type d -exec chmod 755 {} \;
find "$BUILD_DIR" -type d -exec chown "$CURRENT_UID:$CURRENT_GID" {} \;

# Install AWS CLI if it's not already available (though it should be in your image)
if ! command -v aws &> /dev/null
then
    echo "AWS CLI not found, installing..."
    apk update && apk add --no-cache aws-cli
fi

# Set AWS credentials for AWS CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="$AWS_REGION"

# Upload the zip file to S3
S3_KEY="${PROJECT_NAME}/${PROJECT_NAME}-${ZIP_NAME}"
echo "Uploading ${ZIP_PATH} to s3://${S3_BUCKET_NAME}/${S3_KEY}..."
if aws s3 cp "$ZIP_PATH" "s3://${S3_BUCKET_NAME}/${S3_KEY}"; then
  echo "Successfully uploaded ${ZIP_NAME} to s3://${S3_BUCKET_NAME}/${S3_KEY}"
else
  echo "Failed to upload ${ZIP_NAME} to S3" >&2
  exit 1
fi
