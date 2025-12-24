locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  cluster_identifier = (var.cluster_name == null || var.cluster_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.cluster_name

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.cluster_identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_secretsmanager_secret_version" "tf-secrets" {
  count     = var.transit_encryption_enabled ? 1 : 0
  secret_id = var.secret_name
}

resource "aws_elasticache_replication_group" "default" {
  automatic_failover_enabled = var.automatic_failover_enabled
  replication_group_id       = local.cluster_identifier
  description                = "Redis server for ${local.cluster_identifier}."
  node_type                  = var.node_type
  engine                     = var.engine
  engine_version             = var.engine_version
  apply_immediately          = var.apply_immediately
  num_node_groups            = var.num_node_groups
  port                       = var.port
  security_group_ids         = var.security_group_ids
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? jsondecode(data.aws_secretsmanager_secret_version.tf-secrets[0].secret_string)[var.secret_key] : null
  subnet_group_name          = var.subnet_group_name
  tags                       = local.tags
}
