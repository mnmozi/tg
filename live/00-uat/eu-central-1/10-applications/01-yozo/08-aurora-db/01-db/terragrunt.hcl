terraform {
  source = "github.com/mnmozi/tg//modules/db-rds-aurora"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}
dependency "sg" {
  config_path = "../00-sg"
}

inputs = {
  db_name        = "staging-cortechs-ai-db"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"

  db_cluster_parameter_group_family = "aurora-mysql8.0"
  db_parameter_group_family         = "aurora-mysql8.0"

  instance_class      = "db.t4g.large"
  from_backup         = true
  publicly_accessible = "true"
  instances = {
    instance-1 = {
      # instance_class      = "db.t4g.small"
      # publicly_accessible = true
    }
  }
  required_tags = {
    project   = "yozo"
    component = "db"
  }

  tags = {}
  # RDS Module Inputs
  # allocated_storage         = 20
  storage_type              = "aurora"
  create_db_parameter_group = true
  parameter_group_name      = null

  username                    = "master_user"
  password_key                = "master-db-password"
  secret_name                 = "general-passwords"
  manage_master_user_password = false
  port                        = 5432
  storage_encrypted           = true
  apply_immediately           = true

  skip_final_snapshot              = false
  final_snapshot_identifier_prefix = format("final-%s", formatdate("MMM-DD-hh-mm", timestamp()))

  performance_insights_enabled = true

  iam_database_authentication_enabled = false

  publicly_accessible    = true
  vpc_security_group_ids = [dependency.sg.outputs.id] # Replace with actual Security Group IDs
  db_subnet_group_name   = dependency.vpc.outputs.public_database_subnet_group_name

  copy_tags_to_snapshot   = false
  backup_retention_period = 3
}
