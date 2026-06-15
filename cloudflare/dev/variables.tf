variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for lejiend7.com"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Primary domain"
  type        = string
  default     = "lejiend7.com"
}

variable "cloudfront_domain" {
  description = "CloudFront domain for static site"
  type        = string
  default     = "de7bsautsq6ez.cloudfront.net"
}

variable "ec2_ip" {
  description = "EC2 instance IP for API"
  type        = string
  default     = "56.68.99.55"
}
