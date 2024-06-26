terraform {
  backend "s3" {
    bucket         = "res-menu-mgmt-app-api-tfstate"
    key            = "res-menu-mgmt-app.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "res-menu-mgmt-app-api-tfstate-lock"
  }
  required_version = ">=1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  prefix = "${var.prefix}${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Owner       = var.contact
    Project     = var.project
    ManagedBy   = "Terraform"

  }
}


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}