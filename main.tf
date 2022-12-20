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

  tags = var.my_inception_tags
}

# Defines the easy access name of the S3 bucket encryption key
resource "aws_kms_alias" "main" {
  name          = "alias/${local.resource_name}"
  target_key_id = aws_kms_key.main.key_id

  tags = var.my_inception_tags

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

  bucket = "${var.my_inception_organization}-${var.my_inception_environment}-${var.my_inception_domain}-${var.my_inception_project}-tfstate"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = var.my_inception_disable_force_destroy

  versioning = {
    enabled = var.my_inception_enable_versioning
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        # FIXME use count index
        kms_master_key_id = aws_kms_key.tfstate.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = var.my_inception_tags

  depends_on = [
    aws_kms_key.main
  ]
}

################################################################################
# DynamoDB Table
################################################################################

resource "aws_dynamodb_table" "main" {
  name           = "${var.my_inception_organization}_${var.my_inception_environment}_${var.my_inception_domain}_${var.my_inception_project}_tfstatelock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.my_inception_tags
}

################################################################################
# Generate Terraform Backend config file
################################################################################

resource "local_file" "main" {
  for_each = var.generate_backend_configs ? 1 : 0

  content = templatefile("${path.module}/utils/templates/backend_config.tpl", {
    environment = var.my_inception_environment,
    prefix      = local.resource_prefix
    profile     = var.provider_profile,
    region      = var.provider_region,
    site        = var.my_inception_project
    }
  )

  filename        = "${var.backend_configs_location}/${var.resource_prefix}-${each.key}.tfvars"
  file_permission = "0664"
}
