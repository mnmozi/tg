terraform {
  source = "${get_repo_root()}/modules//route53-hosted-zone"
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

  zone_name = "internal.2shta.com"
  vpc_associations = [
    {
      vpc_id     = dependency.vpc.outputs.vpc_id
      vpc_region = include.root.locals.region
    }
  ]
}
