# Defines the lock table

resource "aws_dynamodb_table" "tfstatelock" {
  count          = length(var.my_inception_projects)
  name           = "${var.my_inception_organization}_${var.my_inception_environment}_${var.my_inception_domain}_${var.my_inception_projects[count.index]}_tfstatelock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Component          = "ops"
    ManagedByTerraform = "yes"
  }
}
