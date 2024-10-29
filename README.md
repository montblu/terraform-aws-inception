# Module my_inception

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.41.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.41.0 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3"></a> [s3](#module\_s3) | terraform-aws-modules/s3-bucket/aws | 3.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [local_file.main](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_configs_location"></a> [backend\_configs\_location](#input\_backend\_configs\_location) | Controls where the backend config file is created. | `string` | `"../configs/backends"` | no |
| <a name="input_generate_backend_config_file"></a> [generate\_backend\_config\_file](#input\_generate\_backend\_config\_file) | Controls whether the backend config file is created or not. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the site. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to add to all resources. | `string` | n/a | yes |
| <a name="input_profile"></a> [profile](#input\_profile) | Profile that is going to be placed inside the generated backend config file. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region that is going to be placed inside the generated backend config file. | `string` | n/a | yes |
| <a name="input_s3_disable_force_destroy"></a> [s3\_disable\_force\_destroy](#input\_s3\_disable\_force\_destroy) | Controls whether force destroy is disable in the S3 bucket or enabled. | `bool` | `false` | no |
| <a name="input_s3_enable_versioning"></a> [s3\_enable\_versioning](#input\_s3\_enable\_versioning) | Controls whether versioning is enabled in the S3 bucket or not. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(any)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->