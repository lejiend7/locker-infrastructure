output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.app[*].id
}

output "instance_public_ips" {
  description = "EC2 instance public IPs"
  value       = aws_instance.app[*].public_ip
}

output "instance_private_ips" {
  description = "EC2 instance private IPs"
  value       = aws_instance.app[*].private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.app.id
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
