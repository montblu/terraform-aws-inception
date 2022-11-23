variable "my_inception_organization" { type = string }
variable "my_inception_environment" { type = string }
variable "my_inception_domain" { type = string }
variable "my_inception_project" { type = string }

variable "my_inception_enable_versioning" {
  type    = bool
  default = true
}

variable "my_inception_disable_force_destroy" {
  type    = bool
  default = false
}
