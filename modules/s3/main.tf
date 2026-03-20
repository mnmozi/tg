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

  block_public_acls       = var.static_website != null ? false : true
  block_public_policy     = var.static_website != null ? false : true
  restrict_public_buckets = var.static_website != null ? false : true
  ignore_public_acls      = var.static_website != null ? false : true

  server_side_encryption_configuration = var.static_website != null ? {} : {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
    }
  }

  website = var.static_website != null ? {
    index_document = var.static_website.index_document
    error_document = var.static_website.error_document
  } : {}

  attach_policy = var.static_website != null
  policy = var.static_website != null ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${local.identifier}/*"
      }
    ]
  }) : null

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
