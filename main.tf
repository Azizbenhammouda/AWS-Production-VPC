terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  
  backend "s3" {
    bucket= "my-terraform-state-bucket-12345"  
    key = "prod/vpc/terraform.tfstate"
    region= "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "Production-VPC"
      ManagedBy   = "Terraform"
    }
  }
}


module "vpc" {
  source = "./modules/vpc"

  vpc_cidr= var.vpc_cidr
  environment= var.environment
  availability_zones = var.availability_zones
}

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}