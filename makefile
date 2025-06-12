# Root Makefile for your Terraform + Terragrunt project

# Format all .tf files recursively
fmt-tf:
	@echo "🧼 Formatting Terraform files..."
	@find . -name "*.tf" -exec terraform fmt -recursive {} +

# Format all .hcl files using terragrunt hclfmt
fmt-hcl:
	@echo "🧼 Formatting Terragrunt HCL files..."
	@find . -name "*.hcl" -exec terragrunt hclfmt {} +

# Run both
fmt: fmt-tf fmt-hcl
	@echo "✅ All files formatted successfully."

# Lint: check if files are *not* already formatted (CI usage)
check-fmt:
	@echo "🔍 Checking formatting of .tf files..."
	@terraform fmt -check -recursive || (echo '❌ Some .tf files need formatting! Run `make fmt`.' && exit 1)
	@echo "🔍 Checking formatting of .hcl files..."
	@terragrunt hclfmt --terragrunt-check || (echo '❌ Some .hcl files need formatting! Run `make fmt`.' && exit 1)
	@echo "✅ All files properly formatted."

.PHONY: fmt fmt-tf fmt-hcl check-fmt
