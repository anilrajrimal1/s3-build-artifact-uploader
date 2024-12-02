
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
| `zip_name`              | The name of the zip file to create and upload.                                | ✅            | N/A         |

## Example Workflow

```yaml
      - name: Upload Build Artifact to S3
        uses: anilrajrimal1/s3-build-artifact-uploader@v1
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_region: ${{ secrets.AWS_REGION }}
          s3_bucket_name: ${{ secrets.S3_BUCKET_NAME }}
          project_name: my-project
          zip_name: ${{ github.run_id }}-${{ github.run_number }}.zip #(my-project-1234-1)
```

## How it Works

1. **Build the Project**: You can use any build steps necessary for your project. For example, this could be compiling code, building Docker images, or running a JavaScript build process.
2. **Create a ZIP File**: The action will automatically create a `.zip` file of the build artifacts (e.g., contents of a `dist/` directory).
3. **Upload to S3**: The action will upload the created ZIP file to the specified S3 bucket using the credentials provided.

## Usage

1. Add the action to your workflow YAML file as shown in the example above.
2. Ensure the necessary AWS credentials are stored in the GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `S3_BUCKET_NAME`
3. Run the workflow, and the action will upload the build artifact (ZIP file) to your S3 bucket.

## License
This GitHub Action is licensed under the MIT License.
