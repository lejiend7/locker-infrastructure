resource "aws_security_group" "vpn" {
  name        = "${var.app_name}-${var.environment}-vpn-sg"
  description = "Security group for Pritunl VPN"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Pritunl web UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "OpenVPN UDP"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-vpn-sg"
    Environment = var.environment
  }
}

resource "aws_iam_role" "vpn" {
  name = "${var.app_name}-${var.environment}-vpn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "vpn_ssm" {
  role       = aws_iam_role.vpn.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "vpn" {
  name = "${var.app_name}-${var.environment}-vpn-profile"
  role = aws_iam_role.vpn.name
}

resource "aws_instance" "vpn" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  iam_instance_profile        = aws_iam_instance_profile.vpn.name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  tags = {
    Name        = "${var.app_name}-${var.environment}-vpn"
    Environment = var.environment
  }
}
