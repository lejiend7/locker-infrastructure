# AWS Infrastructure

Manages all AWS resources for the SmartLocker project.

## Resources

| File | Resources |
|---|---|
| `vpc.tf` | VPC, public/private subnets, IGW, EIP, NAT Gateway, route tables |
| `api_gateway.tf` | HTTP API (v2), VPC Link, integration, route, stage, custom domain |
| `alb.tf` | Internal ALB, target group (port 80), listener |
| `ec2.tf` | App EC2 (ARM64/t4g.micro, private subnet), IAM role, SSM, ALB attachment |
| `vpn.tf` | Pritunl VPN EC2 (x86_64/t3.micro, public subnet, AlmaLinux 9), IAM role, SSM |
| `rds.tf` | RDS MySQL 8.0 (db.t4g.micro, private subnet), subnet group |
| `ecr.tf` | ECR repository `locker-backend`, lifecycle policy (keep last 10 images) |
| `s3.tf` | S3 bucket (static website), CloudFront distribution |

## Network Layout

```
VPC 10.0.0.0/16
├── Public subnets  10.0.0.0/24, 10.0.1.0/24   — VPN EC2, NAT Gateway
└── Private subnets 10.0.10.0/24, 10.0.11.0/24 — ALB, App EC2, RDS
```

### Public subnets

Public subnets are associated with the public route table. That route table sends `0.0.0.0/0` to the Internet Gateway.

Resources in public subnets:

| Resource | Why it is public |
|---|---|
| NAT Gateway | Needs internet access so private subnet resources can make outbound connections. It is not an inbound application endpoint. |
| VPN EC2 / Pritunl | Developers need to reach the VPN web UI on TCP 443 and connect OpenVPN on UDP 1194 so they can access private RDS and EC2 endpoints. |

The VPN EC2 instance is the only EC2 instance with `associate_public_ip_address = true`. It is intentionally public because it is the developer entry point into the private network. Developers connect to the VPN first, then reach private resources over VPC-private routes instead of exposing those resources to the internet.

### Private subnets

Private subnets are associated with the private route table. That route table sends outbound `0.0.0.0/0` traffic to the NAT Gateway instead of directly to the Internet Gateway.

Resources in private subnets:

| Resource | Why it is private |
|---|---|
| API Gateway VPC Link | Creates private network connectivity from API Gateway into the VPC. |
| Internal ALB | Receives API traffic from the VPC Link and forwards it to app EC2 instances. |
| App EC2 | Runs the backend application and should not accept direct public traffic. |
| RDS MySQL | Stores application data and must not be reachable from the public internet. |

Private resources can initiate outbound traffic through the NAT Gateway, for example to install packages or reach AWS APIs. Public internet clients cannot initiate connections to private subnet resources.

### RDS exposure

RDS is deliberately not exposed to the internet:

- `aws_db_instance.main` sets `publicly_accessible = false`.
- The DB subnet group uses only `aws_subnet.private[*].id`.
- The RDS security group allows MySQL on port 3306 from the app EC2 security group.
- The RDS security group also allows MySQL from the VPC CIDR, which lets developers connect to the database privately after connecting to the VPN.
- There is no Cloudflare, API Gateway, ALB, or public DNS path directly to RDS.

Normal request path to the database:

```text
User -> Cloudflare -> API Gateway -> VPC Link -> Internal ALB -> App EC2 -> RDS MySQL
```

Private database access path for a developer:

```text
Developer -> VPN -> VPC private address space -> RDS MySQL
```

Private EC2 access path for a developer:

```text
Developer -> VPN -> VPC private address space -> App EC2 private IP
```

## Security Group Chain

```
API Gateway → VPC Link SG → ALB SG → App EC2 SG → RDS SG
```

Detailed security group rules:

| Security group | Inbound allowed | Purpose |
|---|---|---|
| VPC Link SG | No inbound rule; outbound allowed | Used by API Gateway VPC Link to reach the internal ALB. |
| ALB SG | TCP 80 from VPC Link SG | Only API Gateway traffic through the VPC Link can reach the ALB. |
| App EC2 SG | TCP 80 from ALB SG | Only the internal ALB can reach the app over HTTP. |
| App EC2 SG | TCP 22 from VPC CIDR | Developers can SSH to private EC2 IPs only after entering the VPC through VPN. |
| RDS SG | TCP 3306 from App EC2 SG | Backend app can connect to MySQL. |
| RDS SG | TCP 3306 from VPC CIDR | VPN-connected developers can reach MySQL privately from inside the VPC. |
| VPN SG | TCP 443 from internet | Pritunl web UI. |
| VPN SG | UDP 1194 from internet | OpenVPN tunnel traffic. |

SSH (port 22) is open from VPC CIDR only on both EC2 instances. Developers connect through VPN first, then use the EC2 private IP. SSM Session Manager is also available for access without an SSH key.

## Deploy

```bash
cd aws/dev
terraform init
terraform plan
terraform apply
```

### AWS credentials

```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="ap-southeast-5"
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `ap-southeast-5` | AWS region |
| `environment` | `dev` | Environment name |
| `app_name` | `locker` | Application name |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `instance_type` | `t4g.micro` | App EC2 instance type (ARM64) |
| `instance_count` | `1` | Number of app EC2 instances |
| `vpn_instance_type` | `t3.micro` | VPN EC2 instance type (x86_64) |
| `db_instance_class` | `db.t4g.micro` | RDS instance class |
| `db_name` | `locker` | Database name |
| `db_username` | `admin` | Database master username |
| `db_password` | _(required)_ | Database master password |
| `api_domain` | `dev-api-smart-locker.lejiend7.com` | API Gateway custom domain |
| `api_certificate_arn` | — | ACM certificate ARN for API Gateway |
| `cloudfront_alias` | `dev-smart-locker.lejiend7.com` | CloudFront alternate domain |
| `cloudfront_certificate_arn` | — | ACM certificate ARN for CloudFront (us-east-1) |

## Outputs

| Output | Description |
|---|---|
| `api_gateway_url` | Default API Gateway invoke URL |
| `api_gateway_regional_domain_name` | Regional domain — use as CNAME target in Cloudflare |
| `alb_dns_name` | Internal ALB DNS name |
| `rds_endpoint` | RDS MySQL endpoint (`host:3306`) |
| `vpn_public_ip` | VPN EC2 public IP |
| `ecr_repository_url` | ECR URL for pushing Docker images |
| `instance_ids` | App EC2 instance IDs |
| `instance_private_ips` | App EC2 private IPs |
| `cloudfront_domain_name` | CloudFront distribution domain |
| `cloudfront_distribution_id` | CloudFront distribution ID |
| `s3_bucket_name` | S3 bucket name |

## ECR — Push Image

```bash
aws ecr get-login-password --region ap-southeast-5 | \
  docker login --username AWS --password-stdin 905846953702.dkr.ecr.ap-southeast-5.amazonaws.com

docker build -t locker-backend .
docker tag locker-backend:latest 905846953702.dkr.ecr.ap-southeast-5.amazonaws.com/locker-backend:latest
docker push 905846953702.dkr.ecr.ap-southeast-5.amazonaws.com/locker-backend:latest
```

## SSM — Access EC2 (no SSH key needed)

```bash
# App EC2
aws ssm start-session --target i-xxxxxxxxxxxxxxxxx

# VPN EC2
aws ssm start-session --target i-xxxxxxxxxxxxxxxxx
```
