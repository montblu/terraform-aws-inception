resource "local_file" "backend_configs" {
  for_each = var.generate_backend_configs ? 1 : 0

  content = templatefile("${path.module}/utils/templates/backend_config.tpl", {
    environment = var.my_inception_environment,
    prefix      = local.resource_prefix
    profile     = var.provider_profile,
    region      = var.provider_region
    site        = var.my_inception_project,
    }
  )

  filename        = "${var.backend_configs_location}/${var.resource_prefix}-${each.key}.tfvars"
  file_permission = "0664"
}
