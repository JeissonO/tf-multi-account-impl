#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <account_name> <account_id> <deployment_name> <aws_region>"
    echo "Example: $0 networking 111111111111 deployment1 us-west-2"
    exit 1
fi

ACCOUNT_NAME=$1
ACCOUNT_ID=$2
DEPLOYMENT_NAME=$3
AWS_REGION=$4

# Create tfvars only if it doesn't exist
TFVARS_FILE="targets/${ACCOUNT_NAME}.${DEPLOYMENT_NAME}.tfvars"
if [ ! -f "${TFVARS_FILE}" ]; then
    echo "Creating new tfvars file: ${TFVARS_FILE}"
    cat > "${TFVARS_FILE}" << EOF
aws_region = "${AWS_REGION}"
environment = "${ACCOUNT_NAME}"
EOF
else
    echo "Tfvars file already exists: ${TFVARS_FILE}"
fi

# Create deployment directory if it doesn't exist
DEPLOYMENT_DIR="deployments/${ACCOUNT_NAME}/${DEPLOYMENT_NAME}"
mkdir -p "${DEPLOYMENT_DIR}"

# Generate backend.tf
cat > "${DEPLOYMENT_DIR}/backend.tf" << EOF
terraform {
  backend "s3" {
    bucket         = "tf-multi-account-111111111111"
    key            = "${ACCOUNT_NAME}/${DEPLOYMENT_NAME}/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}
EOF

# Generate provider.tf
cat > "${DEPLOYMENT_DIR}/provider.tf" << EOF
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      deployment  = "${DEPLOYMENT_DIR}"
      environment = "${ACCOUNT_NAME}"
      iac         = "tf-multi-account"
      managed_by  = "terraform"      
    }
  }
  assume_role {
    role_arn     = "arn:aws:iam::${ACCOUNT_ID}:role/AWSTFExecution"
    session_name = "tf-multi-account-session"
  }
}
EOF

echo "Generated configuration files in ${DEPLOYMENT_DIR}" 