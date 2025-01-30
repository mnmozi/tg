output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of vpc"
  value       = module.vpc.name
}

output "azs" {
  description = "Names of the azs"
  value       = local.azs
}

output "vpc_CIDR" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "natgw_ids" {
  description = "list of the nat-gateways IDs"
  value       = module.vpc.natgw_ids
}
//------------- PUBLIC -------------

output "public_subnets" {
  description = "list of public subnets"
  value       = module.vpc.public_subnets
}

output "public_route_table_ids" {
  description = "list of the public subnets route table IDs"
  value       = module.vpc.public_route_table_ids
}

output "public_database_subnet_group_name" {
  description = "list of the public database subnets group names"
  value       = try(aws_db_subnet_group.public_db_subnet_group[0].name, "")
}

output "public_subnets_cidr_blocks" {
  description = "list of the public subnet cidrs"
  value       = module.vpc.public_subnets_cidr_blocks
}

//------------- PRIVATE -------------
output "private_subnets" {
  description = "list of the private subnets"
  value       = module.vpc.private_subnets
}

output "private_route_table_ids" {
  description = "list of the private subnets route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "private_database_subnets" {
  description = "list of the private database subnets"
  value       = module.vpc.database_subnets
}

output "private_database_subnet_group_name" {
  description = "list of the private database subnets IDs"
  value       = module.vpc.database_subnet_group_name
}

output "private_elasticache_subnets" {
  description = "list of the private elasticache subnets"
  value       = module.vpc.elasticache_subnets
}

output "private_elasticache_subnet_group_name" {
  description = "list of the private elasticache subnets group names"
  value       = module.vpc.elasticache_subnet_group_name
}

output "private_subnets_cidr_blocks" {
  description = "list of the private subnets cidrs"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "private_database_subnets_cidr_blocks" {
  description = "list of the private database subnets cidrs"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "private_elasticache_subnets_cidr_blocks" {
  description = "list of the private elasticache subnets cidrs"
  value       = module.vpc.elasticache_subnets_cidr_blocks
}

output "private_hosted_zone_id" {
  description = "ID of the private hosted zone"
  value       = coalesce(try(aws_route53_zone.private[0].zone_id, ""), "N/A")
}
