# AWS Infrastructure - Terraform

Manages AWS resources for Locker project.

## Directory Structure

```
aws/
├── dev/              # Development environment
├── staging/          # Staging environment (coming soon)
└── production/       # Production environment (coming soon)
```

## Setup

1. Navigate to environment:
   ```bash
   cd aws/dev
   ```

2. Copy example tfvars:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Configure AWS credentials:
   ```bash
   export AWS_ACCESS_KEY_ID="your-key"
   export AWS_SECRET_ACCESS_KEY="your-secret"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Resources

### EC2
- Basic EC2 instance setup with Ubuntu 22.04 LTS
- Security group with SSH, HTTP, HTTPS access
- IAM role for instance permissions
- Easily scalable with `instance_count` variable

## Environment Variables

- `aws_region` - AWS region (default: us-east-1)
- `environment` - Environment name (default: dev)
- `instance_type` - EC2 instance type (default: t3.micro)
- `instance_count` - Number of instances (default: 1)

## S3 Static Website Hosting

Hosts static website content using S3 + CloudFront CDN.

### Features
- S3 bucket for static assets (HTML, CSS, JS)
- CloudFront CDN for global distribution and HTTPS
- Automatic redirects to HTTPS
- Caching strategy for performance
- Public access blocked at bucket level (CloudFront only)

### Setup

1. Deploy infrastructure:
   ```bash
   terraform apply
   ```

2. Get CloudFront domain from outputs:
   ```bash
   terraform output cloudfront_domain_name
   ```

3. **Option A: Use Cloudflare DNS (Recommended)**
   - Go to cloudflare/dev
   - Add CNAME record:
     - Name: your-domain.com
     - Type: CNAME
     - Content: [CloudFront domain from above]

4. **Option B: Use AWS Route53**
   - Uncomment Route53 resources in `dns.tf`
   - Set `website_domain` variable

5. Upload static files to S3:
   ```bash
   aws s3 sync ./your-website-folder s3://[bucket-name]/ --delete
   ```

### Uploading Content

```bash
# Get bucket name
BUCKET=$(terraform output -raw s3_bucket_name)

# Sync your website files
aws s3 sync ./dist s3://$BUCKET/ --delete

# Clear CloudFront cache
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```
