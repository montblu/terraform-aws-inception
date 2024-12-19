data "aws_caller_identity" "current" {}

locals {
  aws_region_map = {
    "af-south-1"     = "afs1"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-south-1"     = "aps1"
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ca-central-1"   = "cac1"
    "eu-central-1"   = "euc1"
    "eu-west-1"      = "euw1"
    "eu-west-2"      = "euw2"
    "eu-west-3"      = "euw3"
    "me-south-1"     = "mes1"
    "sa-east-1"      = "sae1"
    "us-east-1"      = "use1"
    "us-east-2"      = "use2"
    "us-west-1"      = "usw1"
    "us-west-2"      = "usw2"
  }
  resource_name = "${local.aws_region_map[var.region]}-${var.name_prefix}-site-${var.name}"
}

################################################################################
# S3 Bucket
################################################################################

module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

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
