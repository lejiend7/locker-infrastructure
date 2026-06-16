variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-5"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "locker"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t4g.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 1
}

variable "website_domain" {
  description = "Domain for the website (e.g., example.com)"
  type        = string
  default     = ""
}

variable "cloudfront_alias" {
  description = "Alternate domain name for CloudFront"
  type        = string
  default     = "dev-smart-locker.lejiend7.com"
}

variable "cloudfront_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  type        = string
  default     = "arn:aws:acm:us-east-1:905846953702:certificate/d1d52c2f-e849-4783-9bc9-280519dcf2f6"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
