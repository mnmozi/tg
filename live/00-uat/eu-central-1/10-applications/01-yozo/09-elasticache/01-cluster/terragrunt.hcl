terraform {
  source = "../../../../../../../modules/elasticache"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}
dependency "sg" {
  config_path = "../00-sg"
}
inputs = {
  # cluster_name = "staging-yozo-elasticache"
  required_tags = {
    project   = "yozo"
    component = "elasticache"
  }

  secret_name                = "prod-cortechs"
  secret_key                 = "staging-yozo-elasticache"
  automatic_failover_enabled = false
  node_type                  = "cache.t4g.micro"
  engine                     = "redis"
  engine_version             = "7.1"
  apply_immediately          = true
  num_node_groups            = 1
  port                       = 6379
  security_group_ids         = [dependency.sg.outputs.id]
  transit_encryption_enabled = true
  subnet_group_name          = "staging-vpc" //dependency.vpc.outputs.private_elasticache_subnet_group_name
}