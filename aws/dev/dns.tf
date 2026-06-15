# Optional: Route53 record pointing to CloudFront
# Uncomment and fill in if you want to manage DNS in AWS
# 
# resource "aws_route53_zone" "main" {
#   name = var.website_domain
#
#   tags = {
#     Environment = var.environment
#   }
# }
#
# resource "aws_route53_record" "website" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.website_domain
#   type    = "A"
#
#   alias {
#     name                   = aws_cloudfront_distribution.website.domain_name
#     zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# For Cloudflare DNS (recommended):
# Add CNAME record in Cloudflare pointing your domain to CloudFront domain
# Example:
#   Name: example.com
#   Type: CNAME
#   Content: d123abc.cloudfront.net
