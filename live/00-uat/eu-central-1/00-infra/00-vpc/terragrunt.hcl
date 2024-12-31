terraform {
  source = "../../../../../modules/vpc"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  # VPC Variables
  cidr_b_block = 20
  cidr_prefix  = 16
  subnet_sizes = [2, 2, 2, 6, 6, 6, 8, 8, 8, 8, 8, 8]

  required_tags = {
    vpc_name    = "${include.root.inputs.environment}"
    environment = include.root.inputs.environment
    project     = "infra"
    component   = "networking"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {})

  create_public_db_subnet_group           = false
  create_private_elasticache_subnet_group = true
  enable_nat_gateway                      = false
}
