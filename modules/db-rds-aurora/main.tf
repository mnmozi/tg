locals {
  region              = var.region
  environment         = var.environment
  instance_class      = var.instance_class
  identifier          = coalesce(var.db_name, format("%s-%s-%s", local.environment, local.instance_class, "${var.required_tags.project}-${var.required_tags.component}"))
  snapshot_identifier = coalesce(var.snapshot_identifier, local.identifier)

  use_secret = var.secret_name != null && var.password_key != null
  password   = var.manage_master_user_password ? null : (local.use_secret ? jsondecode(data.aws_secretsmanager_secret_version.master[0].secret_string)[var.password_key] : var.password)

  # Instance-level settings that v10 moved off the cluster: apply the wrapper's
  # defaults to every instance unless the instance overrides them.
  instances = {
    for name, config in var.instances :
    name => merge(
      {
        publicly_accessible          = var.publicly_accessible
        performance_insights_enabled = var.performance_insights_enabled
      },
      config
    )
  }

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_db_cluster_snapshot" "restore" {
  count = var.from_backup ? 1 : 0

  db_cluster_identifier = local.snapshot_identifier
  most_recent           = true
  snapshot_type         = "manual"
}

data "aws_secretsmanager_secret_version" "master" {
  count = local.use_secret && !var.manage_master_user_password ? 1 : 0

  secret_id = var.secret_name
}

module "instance" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "10.4.1"

  name = local.identifier

  engine         = var.engine
  engine_version = var.engine_version

  cluster_instance_class = var.instance_class
  instances              = local.instances

  # Parameter groups: the DB (instance) group keeps a fixed name, the cluster
  # group keeps the upstream name-prefix behaviour, matching what v9 created.
  cluster_parameter_group = var.create_db_parameter_group ? {
    family = var.db_cluster_parameter_group_family
  } : null
  db_parameter_group = var.create_db_parameter_group ? {
    family          = var.db_parameter_group_family
    use_name_prefix = false
  } : null
  cluster_parameter_group_name = var.create_db_parameter_group ? null : var.parameter_group_name

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  master_username = var.username
  # Write-only password: never persisted to state. Bump `password_version`
  # after rotating the secret to push the new value.
  manage_master_user_password = var.manage_master_user_password
  master_password_wo          = local.password
  master_password_wo_version  = var.manage_master_user_password ? null : var.password_version

  port = var.port

  storage_encrypted = var.storage_encrypted
  apply_immediately = var.apply_immediately

  snapshot_identifier = var.from_backup ? data.aws_db_cluster_snapshot.restore[0].id : null

  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot       = var.skip_final_snapshot

  delete_automated_backups                      = var.delete_automated_backups
  backup_retention_period                       = var.backup_retention_period
  cluster_performance_insights_retention_period = var.cluster_performance_insights_retention_period
  deletion_protection                           = var.deletion_protection

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name
  create_security_group  = false
  copy_tags_to_snapshot  = var.copy_tags_to_snapshot
  tags                   = local.tags
}
