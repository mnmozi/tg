terraform {
  source = "${get_repo_root()}/modules//db-rds-aurora"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "${get_parent_terragrunt_dir()}/00-infra/00-vpc"
}

dependency "sg" {
  config_path = "../00-sg"
}

inputs = {
  db_name        = "staging-cortechs-ai-db"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.05.2"

  create_db_parameter_group         = true
  db_cluster_parameter_group_family = "aurora-mysql8.0"
  db_parameter_group_family         = "aurora-mysql8.0"

  instance_class = "db.t4g.large"
  instances = {
    instance-1 = {}
  }

  from_backup = true

  required_tags = {
    project   = "yozo"
    component = "db"
  }

  tags = {}

  storage_type = "aurora"

  username                    = "master_user"
  secret_name                 = "general-passwords"
  password_key                = "master-db-password"
  manage_master_user_password = false
  # MySQL's default is 3306; 5432 is kept because that is what the cluster was created with.
  port              = 5432
  storage_encrypted = true
  apply_immediately = true

  skip_final_snapshot     = false
  backup_retention_period = 3
  copy_tags_to_snapshot   = false

  performance_insights_enabled        = true
  iam_database_authentication_enabled = false

  publicly_accessible    = true
  vpc_security_group_ids = [dependency.sg.outputs.id]
  db_subnet_group_name   = dependency.vpc.outputs.public_database_subnet_group_name
}
