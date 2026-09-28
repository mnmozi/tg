# Root configuration shared by every unit below this directory.
# Units include it with: include "root" { path = find_in_parent_folders("root.hcl") }

locals {
  region      = basename(get_parent_terragrunt_dir()) # region is the directory name
  environment = "<env>"                               # e.g. "staging" - used in state keys, resource names and tags
  s3_bucket   = "<s3-bucket>"                         # state bucket created by modules/remote-state
  kms_key_id  = "<kms-key>"                           # KMS key created by modules/remote-state
  owner       = "Random-Salt"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = local.s3_bucket
    key            = "${local.environment}/${local.region}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    kms_key_id     = local.kms_key_id
    dynamodb_table = "terraform_locking_table"
    use_lockfile   = true # S3 native locking (Terraform >= 1.10); DynamoDB kept for existing runs
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Modules do not ship a provider block; it is generated here so region and
# default behaviour are defined in exactly one place.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region = "${local.region}"
}
PROVIDER
}

inputs = {
  region      = local.region
  environment = local.environment
  owner       = local.owner
  tags = {
    environment = local.environment
    owner       = local.owner
  }
}
