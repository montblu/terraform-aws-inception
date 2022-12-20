data "aws_caller_identity" "current" {}

locals {
  resource_name = "${var.name_prefix}-site-${var.name}"
}

################################################################################
# KMS Key
################################################################################

resource "aws_kms_key" "main" {
  description = "Used to encrypt Terraform state in the S3 Bucket: ${local.resource_name}"
  # Allow IAM to manage access to this key
  # Recall that "To allow access to a KMS CMK [Customer Managed Key], you must use the key policy,
  # either alone or in combination with IAM polices or grants.
  # IAM policies by themselves are not sufficient to allow access to a CMK"
  # Reference: https://docs.aws.amazon.com/kms/latest/developerguide/control-access-overview.html#managing-access
  # So for this key we define a resource policy that allows IAM to manage the acess:
  # https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html#key-policy-default-allow-root-enable-iam
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "enable-iam-user-permissions",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
  # Let's use the maximum delete window in case we need to decrypt something after the key deletion is ordered
  deletion_window_in_days = 30

  tags = var.tags
}

# Defines the easy access name of the S3 bucket encryption key
resource "aws_kms_alias" "main" {
  name          = "alias/${local.resource_name}"
  target_key_id = aws_kms_key.main.key_id

  depends_on = [
    aws_kms_key.main
  ]
}

################################################################################
# S3 Bucket
################################################################################

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.6.0"

  bucket = local.resource_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = var.s3_disable_force_destroy

  versioning = {
    enabled = var.s3_enable_versioning
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.main.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_kms_key.main
  ]
}

################################################################################
# DynamoDB Table
################################################################################

resource "aws_dynamodb_table" "main" {
  name           = local.resource_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

################################################################################
# Generate Terraform Backend config file
################################################################################

resource "local_file" "main" {
  count = var.generate_backend_config_file ? 1 : 0

  content = templatefile("${path.module}/utils/templates/backend_config.tpl", {
    profile       = var.profile,
    region        = var.region,
    resource_name = local.resource_name
    }
  )

  filename        = "${var.backend_configs_location}/${var.name_prefix}-${var.name}.tfvars"
  file_permission = "0664"

  depends_on = [
    aws_dynamodb_table.main,
    module.s3
  ]
}
