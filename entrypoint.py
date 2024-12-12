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
    raise ValueError("All inputs (AWS credentials, region, bucket name, project name, zip name) must be available")

# Get the current user ID and group ID of the runner
current_uid = os.getuid()
current_gid = os.getgid()

# Ensure the current directory is writable by the current user
zip_path = f'./{zip_name}'
if not os.access(os.path.dirname(zip_path), os.W_OK):
    raise PermissionError(f"The directory for {zip_path} is not writable by the current user")

# Create the zip file and set correct file permissions
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk('./dist'):
        for file in files:
            file_path = os.path.join(root, file)
            
            # Fix permissions for each file in dist/
            os.chmod(file_path, 0o755) 
            os.chown(file_path, current_uid, current_gid)
            
            # Add file to the zip archive
            zipf.write(file_path, os.path.relpath(file_path, './dist'))

# Ensure the zip file has the correct permissions
os.chmod(zip_path, 0o644)
os.chown(zip_path, current_uid, current_gid)

# Upload the zip file to S3
s3_client = boto3.client(
    's3',
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region
)

try:
    s3_key = f'{project_name}/{project_name}-{zip_name}'
    s3_client.upload_file(zip_path, s3_bucket_name, s3_key)
    print(f'Successfully uploaded {zip_name} to s3://{s3_bucket_name}/{s3_key}')

except NoCredentialsError:
    print("Credentials not available")
