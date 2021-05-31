# Module my_inception

## Usage

### terraform >= 0.13

```
module "backends" {

  source = "git::ssh://git@bitbucket.org/asolidodev/my_inception.git?ref=0.1.0"

  for_each = toset(var.backends)

  my_inception_organization = var.organization
  my_inception_environment  = var.environment
  my_inception_domain       = var.domain
  my_inception_project      = each.key

}
```

### terraform <= 0.12

```
module "backends" {

  source = "git::ssh://git@bitbucket.org/asolidodev/my_inception.git?ref=0.0.2"

  my_inception_organization = var.organization
  my_inception_environment  = var.environment
  my_inception_domain       = var.domain
  my_inception_projects     = var.inception_projects

}
```
