locals {
  region               = var.region
  environment          = var.environment
  instance_access_type = var.instance_access_type
  identifier           = coalesce(var.db_name, format("%s-%s-%s", local.environment, local.instance_access_type, "${var.required_tags.project}-${var.required_tags.component}"))
  snapshot_identifier  = coalesce(var.snapshot_identifier, local.identifier)

  use_secret = var.secret_name != null && var.password_key != null
  password   = var.manage_master_user_password ? null : (local.use_secret ? jsondecode(data.aws_secretsmanager_secret_version.master[0].secret_string)[var.password_key] : var.password)

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_db_snapshot" "restore" {
  count = var.from_backup ? 1 : 0

  db_instance_identifier = local.snapshot_identifier
  most_recent            = true
  snapshot_type          = "manual"
}

data "aws_secretsmanager_secret_version" "master" {
  count = local.use_secret && !var.manage_master_user_password ? 1 : 0

  secret_id = var.secret_name
}

module "instance" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.2.2"

  identifier = local.identifier

  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family
  major_engine_version = var.major_engine_version

  instance_class = var.instance_class

  create_db_parameter_group       = var.create_db_parameter_group
  parameter_group_name            = var.parameter_group_name
  parameter_group_use_name_prefix = false

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage != 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type

  username = var.username
  # Write-only password: never persisted to state. Bump `password_version`
  # after rotating the secret to push the new value.
  manage_master_user_password = var.manage_master_user_password
  password_wo                 = local.password
  password_wo_version         = var.manage_master_user_password ? null : var.password_version

  port     = var.port
  multi_az = var.multi_az

  storage_encrypted = var.storage_encrypted
  apply_immediately = var.apply_immediately

  snapshot_identifier = var.from_backup ? data.aws_db_snapshot.restore[0].id : null

  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix

  backup_retention_period  = var.backup_retention_period
  delete_automated_backups = var.delete_automated_backups
  deletion_protection      = var.deletion_protection

  performance_insights_enabled        = var.performance_insights_enabled
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  tags                  = local.tags
}
