terraform {
  source = "../../../../../modules/nat-gateway"
}

include "root"{
  path = find_in_parent_folders()
  expose = true
}

dependency "vpc"{
  config_path = "../00-vpc"
}

inputs = {

  required_tags = {
    environment = include.root.inputs.environment
    project     = "infra"
    component   = "networking"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {} )

  subnet_id = dependency.vpc.outputs.private_subnets[0]
  route_table_id = dependency.vpc.outputs.private_route_table_ids[0]
}
