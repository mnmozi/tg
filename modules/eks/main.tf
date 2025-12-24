locals {
  environment = var.environment

  identifier = coalesce(var.cluster_name, format("%s-%s-%s", local.environment, "${var.required_tags.project}-${var.required_tags.component}"))
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

  cluster_name       = local.identifier
  cluster_version    = var.cluster_version
  enable_efa_support = var.enable_efa_support
  enable_irsa        = var.enable_irsa

  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  cluster_compute_config = var.cluster_compute_config

  cluster_addons = var.cluster_addons

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = var.eks_managed_node_groups

  tags = local.tags

}
