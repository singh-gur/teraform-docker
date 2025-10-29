# Terraform with S3-Compatible Backend

This project demonstrates how to configure Terraform to use an S3-compatible endpoint (MinIO) for remote state management while deploying Docker containers.

## Overview

The Terraform configuration sets up:

- S3 backend using S3-compatible endpoint for remote state storage
- Docker provider for container management
- Nginx container deployment (exposed on port 8095)

## Prerequisites

1. **S3-Compatible Storage**: MinIO or other S3-compatible endpoint (default: `https://s3.gsingh.io`)
2. **Terraform**: Installed on your system
3. **Docker**: Running Docker daemon
4. **Just**: Command runner (optional, for convenience)

## Setup

### 1. Configure Backend Credentials

Copy the example backend configuration file and configure your S3-compatible endpoint credentials:

```bash
cp backend.tfvars.example backend.tfvars
```

Edit `backend.tfvars` with your actual S3-compatible configuration:

```hcl
endpoints = { s3 = "https://your-s3-endpoint.com" }
bucket                      = "terraform-state"
access_key                  = "your-access-key"
secret_key                  = "your-secret-key"
region                      = "us-east-1"
skip_requesting_account_id  = true
skip_credentials_validation = true
skip_metadata_api_check     = true
use_path_style              = true
```

### 2. Initialize Terraform

**Option 1: Using Just commands (recommended)**

```bash
just init
```

**Option 2: Manual approach**

```bash
terraform init -backend-config=backend.tfvars
```

**Option 3: Reconfigure existing backend**

```bash
just init-reconfigure
```

## Usage

### Basic Commands

- `terraform plan` - Show execution plan
- `terraform apply` - Apply the configuration
- `terraform destroy` - Destroy resources
- `terraform show` - Show current state

### Using Just Commands

If you have `just` installed, you can use these convenient commands:

```bash
just help            # Show all available commands
just init            # Initialize Terraform with backend configuration
just init-reconfigure # Reconfigure Terraform backend
just fmt             # Format Terraform files
just check           # Validate and format Terraform files
just plan            # Show execution plan
just apply           # Apply configuration
just show            # Show current state
just destroy         # Destroy infrastructure
just clean           # Remove Terraform-generated files
just clean-all       # Remove all files including sensitive config
```

## Backend Configuration Details

The S3 backend is configured with these S3-compatible settings:

- `endpoints`: S3-compatible endpoint URL
- `use_path_style`: Required for MinIO/S3-compatible storage
- `skip_requesting_account_id`: Bypass AWS account ID validation
- `skip_credentials_validation`: Bypass AWS credential validation
- `skip_metadata_api_check`: Disable AWS metadata API calls

## S3-Compatible Storage Setup

### MinIO Setup (Example)

If you need to set up MinIO, you can use Docker:

```bash
docker run -p 9000:9000 -p 9001:9001 \
  --name minio \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  -v minio-data:/data \
  minio/minio server /data --console-address ":9001"
```

Then create a bucket for Terraform state:

```bash
mc alias set local http://localhost:9000 minioadmin minioadmin
mc mb local/terraform-state
```

### Other S3-Compatible Services

This configuration works with any S3-compatible storage service such as:

- DigitalOcean Spaces
- Wasabi
- Ceph
- Any other S3-compatible endpoint

## Security Notes

- Never commit `backend.tfvars` files to version control
- The `.gitignore` file is configured to exclude sensitive files
- Use IAM policies to restrict access to the Terraform state bucket
- Consider enabling state locking and encryption for production use
- Use `just clean-all` to remove sensitive configuration files when needed

## Troubleshooting

### Backend Initialization Issues

If you encounter backend configuration issues, you can reconfigure:

```bash
just init-reconfigure
```

Or manually:
```bash
terraform init -reconfigure -backend-config=backend.tfvars
```

### S3 Connection Issues (301 Errors)

If you get a 301 error about bucket location like this:
```
Error: Failed to get existing workspaces: Unable to list objects in S3 bucket "terraform-state" with prefix "env:/": operation error S3: ListObjectsV2, https response error StatusCode: 301
```

This error occurs when the S3 backend configuration is incomplete. The backend configuration should be provided entirely through the `backend.tfvars` file.

**Solution: Ensure your backend.tfvars has the correct settings:**

```hcl
endpoints = { s3 = "https://s3.gsingh.io" }
bucket                      = "terraform-state"
access_key                  = "your-access-key"
secret_key                  = "your-secret-key"
region                      = "us-east-1"
skip_requesting_account_id  = true
skip_credentials_validation = true
skip_metadata_api_check     = true
use_path_style              = true
```

**Additional troubleshooting steps:**

1. **Verify bucket exists**: Ensure the bucket "terraform-state" exists in your S3-compatible storage
2. **Test connectivity**: Check if you can access the endpoint:

```bash
curl -I https://s3.gsingh.io
```

3. **Check backend.tfvars is being loaded**: Ensure the backend configuration file is being used:

```bash
terraform init -backend-config=backend.tfvars
```

4. **Verify file permissions**: Make sure `backend.tfvars` is readable and contains valid HCL syntax

### Common Issues

1. **Verify S3-compatible storage is running and accessible**
2. **Check endpoint URL and credentials in backend.tfvars**
3. **Ensure the specified bucket exists**
4. **Verify network connectivity to S3 endpoint**
5. **Check that access keys have proper permissions**

### State Locking

For production use, consider setting up DynamoDB or MinIO for state locking by adding to the backend configuration:

```hcl
dynamodb_table = "terraform-locks"
dynamodb_endpoint = "http://localhost:8000"
```

## File Structure

```
.
├── main.tf                    # Main Terraform configuration
├── backend.tfvars.example     # Backend configuration template
├── .gitignore                 # Git ignore rules
├── justfile                   # Just command definitions
└── README.md                  # This file
```

## What Gets Deployed

When you apply this configuration, the following resources will be created:

1. **Docker Image**: Pulls the latest Nginx image
2. **Docker Container**: Creates an Nginx container named "tutorial"
   - Maps internal port 80 to external port 8095
   - Accessible at `http://localhost:8095`

## Verification

After applying the configuration, you can verify the deployment:

```bash
# Check if the container is running
docker ps | grep tutorial

# Access the Nginx welcome page
curl http://localhost:8095

# Or open in your browser
open http://localhost:8095
```
