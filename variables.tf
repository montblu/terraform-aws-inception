variable "my_inception_organization" { type = string }
variable "my_inception_environment" { type = string }
variable "my_inception_domain" { type = string }
variable "my_inception_project" { type = string }

variable "my_inception_tags" {
  type    = map(any)
  default = {}
}

variable "my_inception_enable_versioning" {
  type    = bool
  default = true
}

variable "my_inception_disable_force_destroy" {
  type    = bool
  default = false
}

variable "generate_backend_configs" {
  type    = bool
  default = true
}

variable "backend_configs_location" {
  type    = string
  default = "../configs/backends"
}

variable "provider_profile" {
  type = string
}

variable "provider_region" {
  type = string
}
