terraform {
  source = "${get_repo_root()}/modules//nat-gateway"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../00-vpc"
}

inputs = {
  required_tags = {
    project   = "infra"
    component = "networking"
  }

  tags = merge(include.root.inputs.tags, {})

  subnet_id       = dependency.vpc.outputs.public_subnets[0]
  route_table_ids = dependency.vpc.outputs.private_route_table_ids
}
