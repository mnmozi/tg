locals {
  region      = var.region
  environment = var.environment

  identifier = (var.bucket_name == null || var.bucket_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.bucket_name

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, Name = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.identifier

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning = {
    enabled = var.versioning
  }

  lifecycle_rule = var.noncurrent_version_keep_count != null ? [
    {
      id      = "cleanup-old-versions"
      enabled = true

      noncurrent_version_expiration = {
        newer_noncurrent_versions = var.noncurrent_version_keep_count
        noncurrent_days           = 1
      }
    }
  ] : []

  tags = local.tags
}
