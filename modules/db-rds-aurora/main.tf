locals {
  region              = var.region
  environment         = var.environment
  instance_class      = var.instance_class
  identifier          = coalesce(var.db_name, format("%s-%s-%s", local.environment, local.instance_class, "${var.required_tags.project}-${var.required_tags.component}"))
  snapshot_identifier = coalesce(var.snapshot_identifier, local.identifier)

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}


data "aws_db_cluster_snapshot" "development_final_snapshot" {
  count = var.from_backup ? 1 : 0

  db_cluster_identifier = coalesce(var.snapshot_identifier, local.snapshot_identifier)
  most_recent           = true
  snapshot_type         = "manual"
}


data "aws_secretsmanager_secret_version" "tf-secrets" {
  secret_id = var.secret_name
}

module "instance" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.11.0"

  name = local.identifier

  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  publicly_accessible = var.publicly_accessible

  instances                          = var.instances
  create_db_parameter_group          = var.create_db_parameter_group
  db_cluster_parameter_group_family  = var.db_cluster_parameter_group_family
  db_parameter_group_family          = var.db_parameter_group_family
  db_parameter_group_use_name_prefix = false

  allocated_storage = var.allocated_storage

  master_username             = var.username
  storage_type                = var.storage_type
  manage_master_user_password = false
  master_password             = var.secret_name != null && var.password_key != null ? jsondecode(data.aws_secretsmanager_secret_version.tf-secrets.secret_string)[var.password_key] : var.password

  port = var.port

  storage_encrypted = var.storage_encrypted
  apply_immediately = var.apply_immediately

  snapshot_identifier = var.from_backup && length(data.aws_db_cluster_snapshot.development_final_snapshot) > 0 ? data.aws_db_cluster_snapshot.development_final_snapshot[0].id : null

  final_snapshot_identifier = format("final-%s", formatdate("MMM-DD-hh-mm", timestamp()))

  skip_final_snapshot = var.skip_final_snapshot

  delete_automated_backups                      = var.delete_automated_backups
  performance_insights_enabled                  = var.performance_insights_enabled
  cluster_performance_insights_retention_period = var.cluster_performance_insights_retention_period
  backup_retention_period                       = var.backup_retention_period

  iam_database_authentication_enabled = var.iam_database_authentication_enabled


  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
  create_security_group  = false
  copy_tags_to_snapshot  = var.copy_tags_to_snapshot
  tags                   = local.tags
}
