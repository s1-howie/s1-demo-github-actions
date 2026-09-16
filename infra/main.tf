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

# Finding: wildcard-admin IAM policy.
resource "aws_iam_policy" "app_role_policy" {
  name        = "planex-shipping-api-policy"
  description = "Execution policy for the shipping API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["*"]
      Resource = ["*"]
    }]
  })
}

# Finding: security group open to the entire internet on every port.
resource "aws_security_group" "app" {
  name        = "planex-shipping-api-sg"
  description = "Security group for the shipping API"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
