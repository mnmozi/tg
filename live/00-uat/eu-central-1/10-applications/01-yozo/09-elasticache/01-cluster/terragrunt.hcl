terraform {
  source = "${get_repo_root()}/modules//elasticache"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "sg" {
  config_path = "../00-sg"
}

inputs = {
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

  # The VPC unit does not create ElastiCache subnets (create_elasticache_subnet
  # is false), so this subnet group was created outside Terraform. Switch to
  # the VPC unit's private_elasticache_subnet_group_name output once the VPC
  # manages it.
  subnet_group_name = "staging-vpc"
}
