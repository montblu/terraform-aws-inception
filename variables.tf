variable "name" {
  type        = string
  description = "Name of the site."
}

variable "name_prefix" {
  type        = string
  description = "Prefix to add to all resources."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "A map of tags to add to all resources."
}

variable "s3_enable_versioning" {
  type        = bool
  default     = true
  description = "Controls whether versioning is enabled in the S3 bucket or not."
}

variable "s3_disable_force_destroy" {
  type        = bool
  default     = false
  description = "Controls whether force destroy is disable in the S3 bucket or enabled."
}

variable "generate_backend_config_file" {
  type        = bool
  default     = true
  description = "Controls whether the backend config file is created or not."
}

variable "backend_configs_location" {
  type        = string
  default     = "../configs/backends"
  description = "Controls where the backend config file is created."
}

variable "profile" {
  type        = string
  description = "Profile that is going to be placed inside the generated backend config file."
}

variable "region" {
  type        = string
  description = "Region that is going to be placed inside the generated backend config file."
}
