# Set dotenv filename to load .env file if it exists
dotenv-filename := ".env"

# Initialize Terraform with backend
init:
	@terraform init -backend-config=backend.tfvars

# Initialize Terraform with backend configuration (reconfigure if needed)
init-reconfigure:
	@terraform init -reconfigure -backend-config=backend.tfvars

# Format Terraform files
fmt:
	@terraform fmt

# Validate and format Terraform files
check:
	@terraform fmt
	@terraform validate

# Apply Terraform configuration
apply:
	@terraform apply

# Show current state
show:
	@terraform show

# Destroy infrastructure
destroy:
	@terraform destroy

# Plan Terraform changes
plan:
	@terraform plan

# Clean up all Terraform-generated files and local state
clean:
	@echo "Cleaning up Terraform files..."
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f *.tfstate
	@rm -f *.tfstate.*
	@rm -f terraform.tfplan
	@rm -f crash.log
	@echo "Cleanup complete. All Terraform-generated files removed."

# Clean up including sensitive configuration files
clean-all:
	@echo "Cleaning up all generated and configuration files..."
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f *.tfstate
	@rm -f *.tfstate.*
	@rm -f terraform.tfplan
	@rm -f crash.log
	@rm -f .env
	@rm -f terraform.tfvars
	@rm -f backend.tfvars
	@echo "Complete cleanup finished. All generated and config files removed."

# Setup instructions
help:
	@echo "Terraform with MinIO Backend Setup"
	@echo "==================================="
	@echo ""
	@echo "To get started:"
	@echo "1. Configure your MinIO credentials in backend.tfvars"
	@echo "2. Run 'just init' to initialize Terraform with the MinIO backend"
	@echo ""
	@echo "Available commands:"
	@echo "  init            - Initialize Terraform"
	@echo "  init-reconfigure - Reconfigure Terraform backend"
	@echo "  fmt             - Format Terraform files"
	@echo "  check           - Validate and format Terraform files"
	@echo "  plan            - Show Terraform execution plan"
	@echo "  apply           - Apply Terraform configuration"
	@echo "  show            - Show current state"
	@echo "  destroy         - Destroy infrastructure"
	@echo "  clean           - Remove Terraform-generated files (state, cache, etc.)"
	@echo "  clean-all       - Remove all files including sensitive config (backend.tfvars)"
	@echo "  help            - Show this help message"