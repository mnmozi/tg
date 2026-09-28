terraform {
  source = "${get_repo_root()}/modules//vpc"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  cidr     = "172.28.0.0/16"
  az_count = 2

  required_tags = {
    environment = include.root.inputs.environment
    project     = "infra"
    component   = "networking"
    critical    = "yes"
  }

  tags = merge(include.root.inputs.tags, {})

  create_public_db_subnet_group = false
  enable_nat_gateway            = false

  # Example: tag public subnets per AZ for an EKS cluster's load balancers.
  # public_subnet_tags_per_az = {
  #   1 = { "kubernetes.io/cluster/dev-cluster" = "shared", "kubernetes.io/role/elb" = "1" }
  #   2 = { "kubernetes.io/cluster/dev-cluster" = "shared", "kubernetes.io/role/elb" = "1" }
  # }
}
