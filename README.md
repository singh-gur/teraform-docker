# Terraform with MinIO Backend

This project demonstrates how to configure Terraform to use a MinIO S3-compatible endpoint for state management.

## Overview

The Terraform configuration sets up:
- S3 backend using MinIO endpoint for remote state storage
- Docker provider for container management
- Nginx container deployment

## Prerequisites

1. **MinIO Server**: Running MinIO instance (default: `http://localhost:9000`)
2. **Terraform**: Installed on your system
3. **Docker**: Running Docker daemon
4. **Just**: Command runner (optional, for convenience)

## Setup

### 1. Configure MinIO Credentials

Copy the example environment file and configure your MinIO credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual MinIO configuration:

```bash
# MinIO endpoint URL
export TF_VAR_minio_endpoint="http://localhost:9000"

# MinIO bucket name (must exist in MinIO)
export TF_VAR_minio_bucket="terraform-state"

# MinIO access credentials
export TF_VAR_minio_access_key="your-minio-access-key"
export TF_VAR_minio_secret_key="your-minio-secret-key"
```

### 2. Alternative: Use terraform.tfvars

Instead of environment variables, you can copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Initialize Terraform

**Option 1: Using Just commands (recommended)**

```bash
just init-with-env
```

**Option 2: Manual approach**

```bash
source .env
terraform init
```

**Option 3: Using Just with manual environment loading**

```bash
just setup-env  # Shows how to load variables
source .env && just init
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
just help          # Show all available commands
just setup-env     # Show how to load environment variables
just init-with-env # Initialize Terraform with environment variables
just plan-with-env # Plan Terraform with environment variables
just apply-with-env # Apply Terraform with environment variables
just plan          # Show execution plan (requires manual env loading)
just apply         # Apply configuration (requires manual env loading)
just destroy       # Destroy infrastructure
```

## Backend Configuration Details

The S3 backend is configured with these MinIO-specific settings:

- `endpoint`: MinIO server URL
- `force_path_style`: Required for MinIO compatibility
- `skip_credentials_validation`: Bypass AWS credential validation
- `skip_metadata_api_check`: Disable AWS metadata API calls

## MinIO Setup

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

## Security Notes

- Never commit `.env` or `terraform.tfvars` files to version control
- The `.gitignore` file is configured to exclude sensitive files
- Use IAM policies to restrict access to the Terraform state bucket
- Consider enabling state locking and encryption for production use

## Troubleshooting

### Backend Initialization Issues

If you encounter backend configuration issues, you can reconfigure:

```bash
terraform init -reconfigure
```

### MinIO Connection Issues

1. Verify MinIO is running and accessible
2. Check endpoint URL and credentials
3. Ensure the specified bucket exists
4. Verify network connectivity to MinIO endpoint

### State Locking

For production use, consider setting up DynamoDB or MinIO for state locking by adding to the backend configuration:

```hcl
dynamodb_table = "terraform-locks"
dynamodb_endpoint = "http://localhost:8000"
```

## File Structure

```
.
├── main.tf                 # Main Terraform configuration
├── .env.example           # Environment variables template
├── terraform.tfvars.example # Terraform variables template
├── .gitignore             # Git ignore rules
├── justfile               # Just command definitions
└── README.md              # This file
```