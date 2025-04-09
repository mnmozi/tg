terraform {
  source = "../../../../../modules/route53-hosted-zone"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "../00-vpc"
}

inputs = {

  required_tags = {
    environment = include.root.inputs.environment
    project     = "infra"
    component   = "networking"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {})

  zone_name = "internal.2shta.com"
  vpc_associations = [
    {
      vpc_id     = dependency.outputs.vpc_id
      vpc_region = dependency.root.outputs.region
    }
  ]
}
