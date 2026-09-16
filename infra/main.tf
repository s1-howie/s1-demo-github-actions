# Deliberately misconfigured Terraform for the IaC-scanning demo (see
# ../README.md). This is never applied anywhere - it exists purely as a
# static scan target for `s1-cns-cli scan iac`, which parses HCL directly
# without needing `terraform init`/state.

provider "aws" {
  region = "us-east-1"
}

# Finding: public S3 bucket, no encryption, no versioning.
resource "aws_s3_bucket" "shipments" {
  bucket = "planex-shipments-demo"
}

resource "aws_s3_bucket_public_access_block" "shipments" {
  bucket = aws_s3_bucket.shipments.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Finding: IAM role privilege escalation. A standalone aws_iam_policy with
# wildcard Action/Resource (what used to be here) doesn't actually trip
# anything on this scanner - confirmed live. The privilege-escalation
# checks it does enforce (IAC_SECURITY:AWS:TERRAFORM:iamRoleShouldNotAllow
# PrivilegeEscalationByAction*) key off specific action combinations in an
# *inline* aws_iam_role_policy attached to a real aws_iam_role, so this uses
# the classic 'iam:PassRole' + 'ec2:RunInstances' escalation path (pass this
# role to a new EC2 instance you control) plus 'iam:CreateAccessKey' (mint
# long-lived credentials for any IAM user) instead.
resource "aws_iam_role" "app" {
  name = "planex-shipping-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "app_inline" {
  name = "planex-shipping-api-privesc-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:PassRole",
        "ec2:RunInstances",
        "iam:CreateAccessKey"
      ]
      Resource = ["*"]
    }]
  })
}

# Finding: security group open to the entire internet, but only on the ports
# the app actually needs (HTTP/HTTPS/SSH/PostgreSQL) - each still trips its
# own specific "restrict access" finding, rather than one blanket
# "every port open" finding that doesn't reflect a real app's footprint.
resource "aws_security_group" "app" {
  name        = "planex-shipping-api-sg"
  description = "Security group for the shipping API"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Finding: CloudWatch log group with no customer-managed KMS key -
# intentionally left unencrypted so the policy *would* normally fire, but
# tagged with s1-cns-skip to demonstrate the exception-handling mechanism
# (see the KB's "Exception handling" section) - treat this as "accepted
# risk, reviewed" rather than "fixed".
resource "aws_cloudwatch_log_group" "app" {
  name              = "/planex/shipping-api"
  retention_in_days = 7

  tags = {
    s1-cns-skip = "IAC_SECURITY:AWS:TERRAFORM:cloudwatchLogGroupNotEncrypted"
  }
}
