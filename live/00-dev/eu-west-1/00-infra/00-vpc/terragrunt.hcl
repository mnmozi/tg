terraform {
  source = "${path_relative_from_include()}/../../../modules/vpc"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  # VPC Variables
  # vpc_name = "DEV-VPC"
  # cidr = "172.28.0.0/16"
  # az_count = 2
  # subnets  = ["172.28.1.0/24", "172.28.2.0/24", "172.28.3.0/24", "172.28.4.0/24"]
  create_public_db_subnet_group           = false
  create_private_elasticache_subnet_group = false
  enable_nat_gateway                      = false

  required_tags = {
    vpc_name    = "${include.root.inputs.environment}"
    environment = include.root.inputs.environment
    project     = "infra"
    component   = "networking"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {})
  # private_subnet_tags = {}
  # public_subnet_tags = {}
  # public_subnet_tags_per_az = {
  #   1 = {
  #     "kubernetes.io/cluster/dev-snapii\t" = "shared",
  #     "kubernetes.io/role/elb"             = "1",
  #   }
  #   2 = {
  #     "kubernetes.io/cluster/dev-snapii\t" = "shared",
  #     "kubernetes.io/role/elb"             = "1",
  #   }
  # }
}
