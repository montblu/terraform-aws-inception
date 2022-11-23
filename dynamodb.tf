# Defines the lock table

resource "aws_dynamodb_table" "tfstatelock" {
  name           = "${var.my_inception_organization}_${var.my_inception_environment}_${var.my_inception_domain}_${var.my_inception_project}_tfstatelock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}
