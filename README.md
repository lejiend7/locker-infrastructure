# Locker Infrastructure

Terraform infrastructure as code for the SmartLocker project, split across two providers with separate state backends.

## Architecture

```
Internet
  │
  ▼
Cloudflare (DNS + Proxy)
  │
  ├── dev-smart-locker.lejiend7.com  ──► CloudFront ──► S3 (frontend)
  │
  └── dev-api-smart-locker.lejiend7.com ──► API Gateway (HTTP API)
                                                │
                                           VPC Link
                                                │
                                        Internal ALB (private subnet)
                                                │
                                         EC2 App (private subnet, ARM64)
                                                │
                                         RDS MySQL (private subnet)

dev-vpn.lejiend7.com ──► VPN EC2 / Pritunl (public subnet, x86_64)
```

## Infrastructure Overview

This infrastructure has three main public entry points:

| URL | Purpose | Public entry | Backend destination |
|---|---|---|---|
| `https://dev-smart-locker.lejiend7.com` | Frontend web app | Cloudflare proxied DNS -> CloudFront | S3 static website bucket |
| `https://dev-api-smart-locker.lejiend7.com` | Backend API | Cloudflare proxied DNS -> API Gateway | Private EC2 app through VPC Link and internal ALB |
| `https://dev-vpn.lejiend7.com` | Developer VPN | Cloudflare DNS-only A record -> VPN EC2 public IP | Private access to RDS and EC2 through Pritunl/OpenVPN |

Cloudflare is used for DNS for `lejiend7.com`. AWS owns the compute, networking, database, container registry, frontend storage, and CDN resources.

### Cloudflare layer

Cloudflare only manages DNS records in this repository. The DNS records point friendly subdomains to AWS-managed endpoints.

| Record | Type | Target | Proxied | Meaning |
|---|---|---|---:|---|
| `dev-smart-locker.lejiend7.com` | CNAME | CloudFront distribution domain | Yes | Browser traffic reaches Cloudflare first, then CloudFront. |
| `dev-api-smart-locker.lejiend7.com` | CNAME | API Gateway regional domain | Yes | API traffic reaches Cloudflare first, then API Gateway. |
| `dev-vpn.lejiend7.com` | A | VPN EC2 public IP | No | VPN traffic goes directly to the EC2 public IP because VPN protocols should not pass through the Cloudflare HTTP proxy. |

The AWS and Cloudflare Terraform workspaces are separate. After applying AWS, values like the API Gateway regional domain, CloudFront domain, and VPN public IP are copied into `cloudflare/dev/terraform.tfvars`.

### AWS public edge layer

Some AWS services are public by design but are not inside the VPC:

| Service | Role |
|---|---|
| CloudFront | Public CDN for the frontend. Receives traffic from Cloudflare and fetches static files from S3. |
| API Gateway HTTP API | Public managed API entry point. Receives traffic from Cloudflare and privately forwards API requests into the VPC through VPC Link. |
| S3 website endpoint | Static website origin for frontend files. It is outside the VPC and serves objects to CloudFront. |

These services are the intended public AWS-facing surface. The backend ALB, backend EC2 app, and RDS database are not public entry points.

### AWS VPC layer

The VPC is where the backend application, internal load balancer, VPN, NAT Gateway, and database live. It is split into public and private subnets.

Public subnets are for resources that must have internet routing:

| Resource | Why it is in a public subnet |
|---|---|
| Internet Gateway | Gives the VPC public internet routing. |
| NAT Gateway | Allows private subnet resources to initiate outbound internet access. |
| VPN EC2 / Pritunl | Needs a public IP so developers can connect to the VPN and enter the private VPC network. |

Private subnets are for backend resources that should not accept direct internet traffic:

| Resource | Why it is in a private subnet |
|---|---|
| API Gateway VPC Link | Lets API Gateway reach private VPC resources without exposing them publicly. |
| Internal ALB | Distributes API traffic to app EC2 instances, but only inside the VPC. |
| App EC2 | Runs the backend application without a public IP. |
| RDS MySQL | Stores data and must stay private. |

### TLS and protocol boundaries

| Segment | Protocol | Notes |
|---|---|---|
| Browser -> Cloudflare frontend URL | HTTPS | Cloudflare receives public frontend traffic. |
| Cloudflare -> CloudFront | HTTPS | CloudFront is the frontend AWS edge service. |
| CloudFront -> S3 website endpoint | HTTP | S3 website endpoints only support HTTP. |
| Browser/frontend -> Cloudflare API URL | HTTPS | Cloudflare receives public API traffic. |
| Cloudflare -> API Gateway custom domain | HTTPS | API Gateway uses the configured ACM certificate. |
| API Gateway -> VPC Link -> internal ALB | HTTP on port 80 | Private traffic inside the AWS integration path. |
| Internal ALB -> App EC2 | HTTP on port 80 | App traffic stays inside private subnets. |
| App EC2 -> RDS MySQL | MySQL on port 3306 | Database traffic stays inside the VPC. |
| Developer -> VPN EC2 | TCP 443 and UDP 1194 | Pritunl web UI and OpenVPN. After connection, developers can reach private RDS and EC2 endpoints. |

## Network and Exposure Model

The dev environment creates one VPC: `10.0.0.0/16`. Inside that VPC, resources are split between public and private subnets across two availability zones.

```
VPC 10.0.0.0/16
├── Public subnet 1   10.0.0.0/24    route to Internet Gateway
├── Public subnet 2   10.0.1.0/24    route to Internet Gateway
├── Private subnet 1  10.0.10.0/24   outbound route through NAT Gateway
└── Private subnet 2  10.0.11.0/24   outbound route through NAT Gateway
```

| Resource | Location | Publicly reachable? | Notes |
|---|---|---:|---|
| Cloudflare DNS/proxy | Cloudflare edge | Yes | Public entry point for frontend and API DNS names. |
| CloudFront | AWS edge | Yes | Serves the frontend domain and redirects viewers to HTTPS. |
| S3 website bucket | AWS S3, outside the VPC | Yes for object reads | Static frontend origin. Bucket policy allows public `s3:GetObject`. |
| API Gateway HTTP API | AWS managed public service | Yes | Public API entry point with a custom domain and ACM certificate. |
| API Gateway VPC Link | Private subnets | No | Private bridge from API Gateway into the VPC. |
| Internal ALB | Private subnets | No | `internal = true`; only accepts HTTP from the VPC Link security group. |
| App EC2 | Private subnets | No | Has no public subnet placement. HTTP is only allowed from the ALB security group. |
| RDS MySQL | Private subnets | No | `publicly_accessible = false`; DB subnet group uses private subnets only. |
| NAT Gateway | Public subnet | No inbound app entry | Lets private resources initiate outbound internet access for updates, packages, and AWS calls. |
| VPN EC2 / Pritunl | Public subnet | Yes | Only public EC2 instance. Exposes TCP 443 and UDP 1194 for VPN access. |

Private subnets do not have a direct route to the Internet Gateway. They can initiate outbound traffic through the NAT Gateway, but the internet cannot initiate connections back to resources in those private subnets.

The important protection boundary is the backend chain:

```text
Internet
  -> Cloudflare
  -> API Gateway
  -> VPC Link security group
  -> internal ALB security group
  -> App EC2 security group
  -> RDS security group
```

RDS is not exposed publicly. It is placed in private subnets, marked `publicly_accessible = false`, and only allows MySQL on port 3306 from the app EC2 security group and from the VPC CIDR. That means normal users on the internet cannot connect to the database directly. Database access must come from inside the VPC, such as the app instance or a developer connected through the VPN.

The VPN exists specifically to make private development access easier without opening the database or app servers to the internet. After connecting to the VPN, a developer is effectively inside the VPC network path and can connect to private resources using their private endpoints, such as the RDS endpoint on port 3306 or EC2 private IPs on port 22.

## Request Flow

### Frontend URL

When a user opens `https://dev-smart-locker.lejiend7.com`:

1. The browser asks DNS for `dev-smart-locker.lejiend7.com`.
2. Cloudflare owns the DNS record. Terraform creates a proxied CNAME from `dev-smart-locker` to the CloudFront distribution domain.
3. Because the record is proxied, the browser connects to Cloudflare first over HTTPS.
4. Cloudflare forwards the request to AWS CloudFront.
5. CloudFront serves the static frontend from the S3 website origin.
6. S3 returns `index.html` or the requested static asset. CloudFront caches cacheable responses using the configured default TTL of 3600 seconds.

The S3 bucket is configured as a static website origin and is publicly readable. CloudFront enforces HTTPS for viewers with `viewer_protocol_policy = "redirect-to-https"`, while the CloudFront-to-S3 website origin connection uses HTTP because S3 website endpoints do not support HTTPS.

### API URL

When the frontend or a user calls `https://dev-api-smart-locker.lejiend7.com/...`:

1. The browser asks DNS for `dev-api-smart-locker.lejiend7.com`.
2. Cloudflare owns the DNS record. Terraform creates a proxied CNAME from `dev-api-smart-locker` to the API Gateway regional domain name.
3. The browser connects to Cloudflare over HTTPS, then Cloudflare forwards the request to the API Gateway custom domain.
4. API Gateway terminates TLS using the ACM certificate configured by `api_certificate_arn`.
5. API Gateway matches the default route `ANY /{proxy+}` and sends the request through an HTTP proxy integration.
6. The integration uses an API Gateway VPC Link deployed into the private subnets.
7. The VPC Link reaches the internal Application Load Balancer on port 80.
8. The internal ALB forwards the request to the registered EC2 app instance target on port 80.
9. The app handles the request. If it needs persistence, it connects privately to the RDS MySQL instance on port 3306.
10. The response returns over the same path: EC2 app -> internal ALB -> VPC Link -> API Gateway -> Cloudflare -> browser.

Only Cloudflare and API Gateway are public on the API path. The VPC Link, ALB, app EC2 instance, and RDS database are inside the VPC. The ALB, app EC2 instance, and RDS database live in private subnets, so users never connect to them directly.

### Developer VPN URL

When a developer opens `https://dev-vpn.lejiend7.com` or connects an OpenVPN client:

1. Cloudflare resolves `dev-vpn.lejiend7.com` as an unproxied A record pointing directly to the VPN EC2 public IP.
2. The VPN instance lives in a public subnet and has a public IP.
3. Its security group allows Pritunl web UI traffic on TCP 443 and OpenVPN traffic on UDP 1194 from the internet.
4. After connecting to the VPN, developers can reach private VPC resources without exposing those resources publicly.
5. Developers can connect to RDS MySQL privately on port 3306 because the RDS security group allows traffic from the VPC CIDR.
6. Developers can connect to EC2 privately, for example SSH to private EC2 addresses on port 22 where the EC2 security group allows VPC CIDR access.

The VPN host also has SSM enabled, so AWS Systems Manager Session Manager can be used for administrative access without an SSH key.

## Directory Structure

```
locker-infrastructure/
├── aws/
│   └── dev/
│       ├── vpc.tf              # VPC, subnets, IGW, NAT Gateway
│       ├── api_gateway.tf      # HTTP API, VPC Link, custom domain
│       ├── alb.tf              # Internal ALB + target group
│       ├── ec2.tf              # App EC2 (ARM64, private subnet) + IAM + SSM
│       ├── vpn.tf              # Pritunl VPN EC2 (x86_64, public subnet) + IAM + SSM
│       ├── rds.tf              # RDS MySQL 8.0 (private subnet)
│       ├── ecr.tf              # ECR repository for locker-backend
│       ├── s3.tf               # S3 + CloudFront for frontend
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── cloudflare/
│   └── dev/
│       ├── dns.tf              # CNAME/A records for all subdomains
│       ├── variables.tf
│       └── terraform.tfvars
├── .github/
│   └── workflows/
│       └── terraform-validate.yml
└── README.md
```

## Providers

| Provider | Manages | State Bucket |
|---|---|---|
| AWS | VPC, API Gateway, ALB, EC2, RDS, ECR, S3, CloudFront | S3 (ap-southeast-5) |
| Cloudflare | DNS records for lejiend7.com | S3 (ap-southeast-5) |

The two workspaces have separate state backends and are not linked. Shared values (e.g. API Gateway domain) are passed manually via `terraform output` → `terraform.tfvars`.

## Quick Start

### AWS

```bash
cd aws/dev
terraform init
terraform plan
terraform apply
```

### Cloudflare

After AWS apply, copy the `api_gateway_regional_domain_name` output into `cloudflare/dev/terraform.tfvars`:

```bash
cd aws/dev && terraform output api_gateway_regional_domain_name
# paste value into cloudflare/dev/terraform.tfvars -> api_gateway_domain

cd cloudflare/dev
terraform init
terraform plan
terraform apply
```

## CI

GitHub Actions validates Terraform on every PR via `.github/workflows/terraform-validate.yml`:
- `terraform init -backend=false`
- `terraform validate`
- `terraform fmt -check -recursive`

Runs as two separate jobs: `validate-aws` and `validate-cloudflare`.

## Future Evolution (Terragrunt + Terraform Modules)

As the project grows in complexity and we need to manage multiple environments with reusable components, we will introduce:
- **Terragrunt**: For managing Terraform configurations across multiple environments
- **Terraform Modules**: For reusable, composable infrastructure components
- **Remote State Management**: Centralized state backend with locking
- **Automated Workflows**: CI/CD pipeline for infrastructure changes

## Environments

| Environment | Status |
|---|---|
| dev | Active |
| staging | Planned |
| production | Planned |
