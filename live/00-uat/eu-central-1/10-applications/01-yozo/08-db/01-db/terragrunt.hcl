terraform {
  source = "../../../../../../../modules/db"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/${path_relative_from_include()}/00-infra/00-vpc"
}
dependency "sg" {
  config_path = "../00-sg"
}

inputs = {
  db_name              = "staging-cortechs-ai-db"
  instance_access_type = "private"
  from_backup          = true
  required_tags = {
    project   = "yozo"
    component = "db"
  }

  tags = {}
  # RDS Module Inputs
  engine                    = "postgres"
  engine_version            = "14.12"
  family                    = "postgres14"
  instance_class            = "db.t4g.small"
  allocated_storage         = 20
  max_allocated_storage     = 30
  create_db_parameter_group = true
  parameter_group_name      = null

  username                    = "postgres"
  password_key                = "staging_master_db_password"
  secret_name                 = "prod-cortechs"
  manage_master_user_password = false
  port                        = 5432
  multi_az                    = false
  storage_encrypted           = true
  apply_immediately           = true

  skip_final_snapshot              = false
  final_snapshot_identifier_prefix = format("final-%s", formatdate("MMM-DD-hh-mm", timestamp()))

  performance_insights_enabled        = true
  iam_database_authentication_enabled = false

  publicly_accessible    = false
  vpc_security_group_ids = [dependency.sg.outputs.id] # Replace with actual Security Group IDs
  db_subnet_group_name   = dependency.vpc.outputs.private_database_subnet_group_name

  copy_tags_to_snapshot   = true
  backup_retention_period = 3
}
