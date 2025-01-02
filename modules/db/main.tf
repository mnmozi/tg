locals {
  region               = var.region
  environment          = var.environment
  instance_access_type = var.instance_access_type
  identifier           = coalesce(var.db_name, format("%s-%s-%s", local.environment, local.instance_access_type, "${var.required_tags.project}-${var.required_tags.component}"))
  snapshot_identifier  = coalesce(var.snapshot_identifier, local.identifier)

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}


data "aws_db_snapshot" "development_final_snapshot" {
  count = var.from_backup ? 1 : 0

  db_instance_identifier = local.snapshot_identifier
  most_recent            = true
  snapshot_type          = "manual"
}


data "aws_secretsmanager_secret_version" "tf-secrets" {
  secret_id = var.secret_name
}

module "instance" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.6.0"

  identifier = local.identifier

  engine         = var.engine
  engine_version = var.engine_version
  family         = var.family

  instance_class = var.instance_class

  create_db_parameter_group       = var.create_db_parameter_group
  parameter_group_name            = var.parameter_group_name
  parameter_group_use_name_prefix = false

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage != 0 ? var.max_allocated_storage : null

  username                    = var.username
  storage_type                = var.storage_type
  manage_master_user_password = false
  password                    = var.secret_name != null && var.password_key != null ? jsondecode(data.aws_secretsmanager_secret_version.tf-secrets.secret_string)[var.password_key] : var.password

  port     = var.port
  multi_az = var.multi_az

  storage_encrypted = var.storage_encrypted
  apply_immediately = var.apply_immediately

  snapshot_identifier = var.from_backup && length(data.aws_db_snapshot.development_final_snapshot) > 0 ? data.aws_db_snapshot.development_final_snapshot[0].id : null

  final_snapshot_identifier_prefix = format("final-%s", formatdate("MMM-DD-hh-mm", timestamp()))

  skip_final_snapshot = var.skip_final_snapshot

  # backup_retention_period      = "4"
  # delete_automated_backups     = false
  performance_insights_enabled = var.performance_insights_enabled

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  publicly_accessible    = var.publicly_accessible
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  copy_tags_to_snapshot = var.copy_tags_to_snapshot
  tags                  = local.tags
}
