terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # This pins the version to 5.x
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
