################################################################################
# S3 Bucket
################################################################################

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.14.1"

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
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
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
    module.s3
  ]
}
