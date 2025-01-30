locals {
  region      = var.region
  environment = var.environment

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )

  cidr = var.cidr

  azs = var.az_count == 1 ? ["${var.region}a"] : var.az_count == 2 ? ["${var.region}a", "${var.region}b"] : ["${var.region}a", "${var.region}b", "${var.region}c"]

  auto_generated_subnets = cidrsubnets(local.cidr, tolist(var.subnet_sizes)...)
  final_subnets          = length(var.subnets) > 0 ? var.subnets : local.auto_generated_subnets

  vpc_identifier = (var.vpc_name == null) ? "${var.environment}" : var.vpc_name

  private_subnet_count     = var.az_count * var.subnets_per_az.private
  public_subnet_count      = var.az_count * var.subnets_per_az.public
  database_subnet_count    = var.create_database_subnet ? var.az_count * var.subnets_per_az.database : 0
  elasticache_subnet_count = var.create_elasticache_subnet ? var.az_count * var.subnets_per_az.elasticache : 0

  public_subnets      = slice(local.final_subnets, 0, local.private_subnet_count)
  private_subnets     = slice(local.final_subnets, local.private_subnet_count, local.private_subnet_count + local.public_subnet_count)
  database_subnets    = var.create_database_subnet ? slice(local.final_subnets, local.private_subnet_count + local.public_subnet_count, local.private_subnet_count + local.public_subnet_count + local.database_subnet_count) : []
  elasticache_subnets = var.create_elasticache_subnet ? slice(local.final_subnets, local.private_subnet_count + local.public_subnet_count + local.database_subnet_count, local.private_subnet_count + local.public_subnet_count + local.database_subnet_count + local.elasticache_subnet_count) : []

  az_keys      = range(1, length(local.azs) + 1)
  az_index_map = zipmap(local.az_keys, local.azs)
  public_subnet_tags_by_az = tomap({
    for number, tags in var.public_subnet_tags_per_az :
    local.az_index_map[number] => tags
  })
  private_subnet_tags_by_az = tomap({
    for number, tags in var.private_subnet_tags_per_az :
    local.az_index_map[number] => tags
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = local.vpc_identifier
  cidr = local.cidr
  azs  = local.azs

  private_subnets     = local.private_subnets
  public_subnets      = local.public_subnets
  database_subnets    = local.database_subnets
  elasticache_subnets = local.elasticache_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false

  enable_flow_log               = false
  manage_default_security_group = true

  default_security_group_ingress = [
    {
      self        = true,
      description = "Enable all incoming traffic from self"
      protocol    = "-1"
    },
    {
      cidr_blocks = local.cidr
      description = "Enable all incoming traffic from the VPC CIDR"
      protocol    = "-1"
    },
  ]

  default_security_group_egress = [
    {
      description = "Enable all outgoing traffic"
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1"
    },
  ]

  tags                       = merge(local.tags, var.tags)
  private_subnet_tags        = var.private_subnet_tags
  public_subnet_tags         = var.public_subnet_tags
  private_subnet_tags_per_az = local.private_subnet_tags_by_az
  public_subnet_tags_per_az  = local.public_subnet_tags_by_az
}

resource "aws_db_subnet_group" "public_db_subnet_group" {
  count      = var.create_public_db_subnet_group ? 1 : 0
  name       = "${local.vpc_identifier}-public-subnets"
  subnet_ids = module.vpc.database_subnets
  tags       = merge(local.tags)
}

resource "aws_route53_zone" "private" {
  count = var.private_hosted_zone ? 1 : 0

  name = var.private_hosted_zone_name != "" ? var.private_hosted_zone_name : "${local.region}-${local.vpc_identifier}.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
# resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
#   count      = var.create_elasticache_subnet ? 1 : 0
#   name       = "${local.vpc_identifier}-elasticache-subnets"
#   subnet_ids = module.vpc.elasticache_subnets
#   tags       = merge(local.tags)
# }
