
# S3 bucket that keeps the terraform state
resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.my_inception_organization}-${var.my_inception_environment}-${var.my_inception_domain}-${var.my_inception_project}-tfstate"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
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
