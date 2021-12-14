# Defines the lock table

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.1.0"

  name           = "${var.my_inception_organization}_${var.my_inception_environment}_${var.my_inception_domain}_${var.my_inception_project}_tfstatelock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Component          = "ops"
    ManagedByTerraform = "yes"
  }
}
