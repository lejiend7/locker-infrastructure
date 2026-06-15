terraform {
  required_version = ">= 1.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state-cloudflare-lejiend"
    key    = "cloudflare/dev/terraform.tfstate"
    region = "ap-southeast-5"
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
