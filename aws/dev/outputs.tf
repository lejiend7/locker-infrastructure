output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_gateway_regional_domain_name" {
  description = "API Gateway regional domain name — use this as the CNAME target in Cloudflare"
  value       = aws_apigatewayv2_domain_name.main.domain_name_configuration[0].target_domain_name
}

output "alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.main.endpoint
}

output "vpn_public_ip" {
  description = "VPN EC2 public IP"
  value       = aws_instance.vpn.public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL for locker-backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "instance_ids" {
  description = "EC2 app instance IDs"
  value       = aws_instance.app[*].id
}

output "instance_private_ips" {
  description = "EC2 app instance private IPs"
  value       = aws_instance.app[*].private_ip
}

output "s3_bucket_name" {
  description = "S3 bucket name for static website"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}
