# We'll use an encryption key to encrypt the terraform state
resource "aws_kms_key" "tfstate" {
  count       = length(var.my_inception_projects)
  description = "Used to encrypt tfstate in the s3_bucket ${var.my_inception_organization}-${var.my_inception_environment}-${var.my_inception_domain}-${var.my_inception_projects[count.index]}"
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
  tags = {
    Component          = "ops"
    ManagedByTerraform = "yes"
  }
}

# Defines the easy access name of the S3 bucket encryption key
resource "aws_kms_alias" "tfstate" {
  count         = length(var.my_inception_projects)
  name          = "alias/${var.my_inception_organization}_${var.my_inception_environment}_${var.my_inception_domain}_${var.my_inception_projects[count.index]}"
  target_key_id = aws_kms_key.tfstate.*.key_id[count.index]
}


# S3 bucket that keeps the terraform state
resource "aws_s3_bucket" "tfstate" {
  count  = length(var.my_inception_projects)
  bucket = "${var.my_inception_organization}-${var.my_inception_environment}-${var.my_inception_domain}-${var.my_inception_projects[count.index]}-tfstate"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # FIXME use count index
        kms_master_key_id = aws_kms_key.tfstate.*.arn[count.index]
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags = {
    Component          = "ops"
    ManagedByTerraform = "yes"
  }
}
data "aws_caller_identity" "current" {}
