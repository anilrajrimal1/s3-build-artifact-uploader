
# S3 Build Artifact Uploader

This GitHub Action uploads build artifacts (e.g., dist--> zip files) to an AWS S3 bucket. It allows you to automate the process of storing build outputs in S3, making them easily accessible for further deployment or archiving.

## Inputs

| **Input**              | **Description**                                                              | **Required** | **Default** |
|------------------------|------------------------------------------------------------------------------|--------------|-------------|
| `aws_access_key_id`     | The AWS Access Key ID for authentication.                                    | ✅            | N/A         |
| `aws_secret_access_key` | The AWS Secret Access Key for authentication.                                | ✅            | N/A         |
| `aws_region`            | The AWS region where your S3 bucket is located.                              | ✅            | N/A         |
| `s3_bucket_name`        | The name of the S3 bucket to upload the build artifact to.                    | ✅            | N/A         |
| `project_name`          | The name of your project (used for organizing the artifact).                 | ✅            | N/A         |
| `zip_name`              | The name of the zip file to create and upload.(will attach to project_name )                                | ✅            | N/A         |

## Example Workflow

```yaml
name: Demo Workflow
on:
  push:
    branches:
      - staging
  workflow_dispatch:

env:
  AWS_REGION: ap-south-1
  PROJECT_NAME: Your-Project-Name
  S3_BUCKET_NAME: Your-Bucket-Name

jobs:
  upload-artifact:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Upload Build Artifact to S3
        uses: anilrajrimal1/s3-build-artifact-uploader@v1.0.0
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_region: ${{ env.AWS_REGION }}
          s3_bucket_name: ${{ env.S3_BUCKET_NAME }}
          project_name: ${{ env.PROJECT_NAME }}
          zip_name: ${{ github.ref_name }}-${{ github.run_id }}-${{ github.run_number }}.zip

```

## How it Works

This action will upload the build artifacts  (dist) -> ZIP file to your S3 bucket. You can customize the zip-name (if you add it as mine, the script will take care of the naming convention as (PROJECT_NAME-BRANCH-1234-1.zip)). 
- The action uses boto3 to interact with AWS S3.
- The zipped file will be uploaded to AWS S3.
- You can download it using my `anilrajrimal1/s3-build-artifact-downloader@v1.0.0` action.

## Usage

1. Add the action to your workflow YAML file as shown in the example above.
2. Ensure the necessary AWS credentials are stored in the GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Run the workflow, and the action will upload the build artifact (ZIP file) to your S3 bucket.

## License
This GitHub Action is licensed under the MIT License.
