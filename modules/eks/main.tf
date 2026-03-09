locals {
  environment = var.environment

  identifier = coalesce(var.cluster_name, format("%s-%s-%s", local.environment, var.required_tags.project, var.required_tags.component))

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, "Name" = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = local.identifier
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  authentication_mode                      = var.authentication_mode

  cluster_addons             = var.cluster_addons
  cluster_enabled_log_types  = var.cluster_enabled_log_types
  create_kms_key             = var.create_kms_key
  cluster_encryption_config  = var.cluster_encryption_config

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = length(var.control_plane_subnet_ids) > 0 ? var.control_plane_subnet_ids : var.subnet_ids

  eks_managed_node_groups  = var.eks_managed_node_groups
  self_managed_node_groups = var.self_managed_node_groups
  fargate_profiles         = var.fargate_profiles

  access_entries = var.access_entries

  node_security_group_additional_rules    = var.node_security_group_additional_rules
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  tags = local.tags
}
