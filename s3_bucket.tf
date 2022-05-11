module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.2.0"

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

  tags = {
    Component          = "ops"
    ManagedByTerraform = "yes"
  }
}
