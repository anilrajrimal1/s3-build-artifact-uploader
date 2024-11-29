import os
import zipfile
import boto3
from botocore.exceptions import NoCredentialsError

# Get inputs from environment variables
aws_access_key_id = os.getenv('INPUT_AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('INPUT_AWS_SECRET_ACCESS_KEY')
aws_region = os.getenv('INPUT_AWS_REGION')
s3_bucket_name = os.getenv('INPUT_S3_BUCKET_NAME')
project_name = os.getenv('INPUT_PROJECT_NAME')
zip_name = os.getenv('INPUT_ZIP_NAME')

# Ensure all inputs are provided
if not all([aws_access_key_id, aws_secret_access_key, aws_region, s3_bucket_name, project_name, zip_name]):
    raise ValueError("All inputs must be provided")

# Create a zip file from the 'dist' directory
build_dir = './dist'
zip_path = f'./{zip_name}'

with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(build_dir):
        for file in files:
            zipf.write(os.path.join(root, file), os.path.relpath(os.path.join(root, file), build_dir))

# Upload the zip file to S3
s3_client = boto3.client(
    's3',
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)

try:
    s3_client.upload_file(zip_path, s3_bucket_name, f'{project_name}-{zip_name}')
    print(f'Successfully uploaded {zip_name} to s3://{s3_bucket_name}/{project_name}-{zip_name}')
except NoCredentialsError:
    print("Credentials not available")
