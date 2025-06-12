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
      deployment  = "deployments/networking/vpc"
      environment = "networking"
      iac         = "tf-multi-account"
      managed_by  = "terraform"      
    }
  }
  assume_role {
    role_arn     = "arn:aws:iam::222222222222:role/AWSTFExecution"
    session_name = "tf-multi-account-session"
  }
}
