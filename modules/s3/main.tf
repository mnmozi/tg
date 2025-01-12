# locals {
#   region      = var.region
#   environment = var.environment

#   # Naming variables
#   identifier = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"

#   # Merge required tags with additional tags
#   tags = merge(
#     var.required_tags,
#     var.tags,
#     { "environment" = var.environment, Name = local.identifier },
#     var.owner != null ? { "owner" = var.owner } : {}
#   )
# }

# module "releases-bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"

#   bucket = "logs-trial-${local.company_name}"

#   #   acl                     = "private"
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         sse_algorithm = "aws:kms"
#       }
#     }
#   }

#   # logging = {
#   #   target_bucket = module.logging-bucket.s3_bucket_id
#   #   target_prefix = "lambda-releases-logging/"
#   # }

#   lifecycle_rule = [{
#     id = "deleting-old-files"

#     status = "Enabled"
#     # noncurrent_version_expiration = {
#     #   days = 1 # This will delete noncurrent (previous) versions of the object after 1 day
#     # }
#     expiration = {
#       days = 1
#       # expired_object_delete_marker = true
#     }
#     noncurrent_version_expiration = {
#       noncurrent_days = 1
#     }
#   }]

#   versioning = {
#     enabled = false
#   }

#   tags = local.tags
# }

