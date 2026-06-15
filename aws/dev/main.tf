terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state-lejiend"
    key    = "aws/dev/terraform.tfstate"
    region = "ap-southeast-5"
  }
}

provider "aws" {
  region = var.aws_region
}
