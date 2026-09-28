terraform {
  source = "${get_repo_root()}/modules//vpc"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  # 10.1.0.0/16 is the module default and what is deployed; keep it explicit.
  cidr         = "10.1.0.0/16"
  subnet_sizes = [2, 2, 2, 6, 6, 6, 8, 8, 8, 8, 8, 8]

  required_tags = {
    environment = include.root.inputs.environment
    project     = "infra"
    component   = "networking"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {})

  create_public_db_subnet_group = false
  enable_nat_gateway            = false
}
