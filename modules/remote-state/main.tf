locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  identifier = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

module "remote_state" {
  source                      = "nozaq/remote-state-s3-backend/aws"
  enable_replication          = var.enable_replication
  dynamodb_table_name         = var.dynamodb_table_name
  override_s3_bucket_name     = true
  s3_bucket_name              = var.s3_bucket_name
  terraform_iam_policy_create = false
  tags                        = local.tags
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

output "remote_state_module" {
  value = module.remote_state
}
