locals {
  region      = var.region
  environment = var.environment

  # Naming variables
  lt_identifier         = (var.lt_name == null || var.lt_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.lt_name
  iam_policy_identifier = (var.iam_policy_name == null || var.iam_policy_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.iam_policy_name
  iam_role_identifier   = (var.iam_role_name == null || var.iam_role_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.iam_role_name


  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
  mapped_arch = lookup({
    "amazon-linux"     = var.arch                                  # Amazon Linux uses x86_64 or arm64
    "amazon-linux-ecs" = var.arch                                  # Amazon Linux uses x86_64 or arm64
    "ubuntu"           = var.arch == "x86_64" ? "amd64" : var.arch # Ubuntu uses amd64 for x86_64
  }, var.distro, null)

  # Map the SSM path for each distribution
  ssm_path = lookup({
    "amazon-linux"     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-${local.mapped_arch}"
    "ubuntu"           = "/aws/service/canonical/ubuntu/server/24.04/stable/current/${local.mapped_arch}/hvm/ebs-gp3/ami-id"
    "amazon-linux-ecs" = "/aws/service/ecs/optimized-ami/amazon-linux-2023/${local.mapped_arch == "arm64" ? "${local.mapped_arch}/" : ""}recommended/image_id"
  }, var.distro, null)
}

data "aws_ssm_parameter" "latest_ami" {
  count = local.ssm_path != null ? 1 : 0
  name  = local.ssm_path
}

data "aws_secretsmanager_secret_version" "service_secret" {
  for_each  = toset(var.secrets_names)
  secret_id = each.value
}

resource "aws_iam_policy" "role_policy" {
  count = (
    length(keys(data.aws_secretsmanager_secret_version.service_secret)) > 0 ||
    length(var.custom_role_statements) > 0
  ) ? 1 : 0

  name        = local.iam_policy_identifier
  description = "Task role policy for ECS containers"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        for secret in keys(data.aws_secretsmanager_secret_version.service_secret) : {
          "Effect" : "Allow",
          "Action" : ["secretsmanager:GetSecretValue"],
          "Resource" : data.aws_secretsmanager_secret_version.service_secret[secret].arn
        }
      ],
      var.custom_role_statements
    )
  })
  tags = merge(local.tags, { "Name" : local.iam_policy_identifier })
}

module "role" {
  source            = "github.com/mnmozi/tg//modules/ami-role"
  name              = local.iam_role_identifier
  is_instance       = true
  principal_service = ["ec2.amazonaws.com"]

  policies = merge(
    var.linked_policies # Merge additional policies
    ,
    {
      amazon_ec2_rolefor_ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    },
    length(aws_iam_policy.role_policy) > 0 ? {
      custom_policy = aws_iam_policy.role_policy[0].arn
    } : {}
  )
  region = var.region
  tags   = merge(local.tags, { "Name" : local.iam_role_identifier })
}

resource "aws_launch_template" "lt" {
  default_version = var.default_version
  name            = local.lt_identifier
  image_id        = var.iam != null ? var.iam : data.aws_ssm_parameter.latest_ami[0].value
  instance_type   = var.instance_type
  key_name        = var.key_name

  dynamic "instance_market_options" {
    for_each = var.spot_enabled ? [1] : [] # Add block only if spot instances are enabled
    content {
      market_type = "spot"

      spot_options {
        spot_instance_type             = var.spot_instance_type
        instance_interruption_behavior = var.instance_interruption_behavior
        valid_until                    = var.spot_instance_type == "persistent" && var.valid_until != null ? var.valid_until : null
      }
    }
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  disable_api_stop        = var.disable_api_stop
  disable_api_termination = var.disable_api_termination

  ebs_optimized = var.ebs_optimized

  iam_instance_profile {
    name = module.role.aws_iam_instance_profile
  }
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        delete_on_termination = block_device_mappings.value.ebs.delete_on_termination
        encrypted             = block_device_mappings.value.ebs.encrypted
        iops                  = block_device_mappings.value.ebs.iops
        throughput            = block_device_mappings.value.ebs.throughput
        volume_size           = block_device_mappings.value.ebs.volume_size
        volume_type           = block_device_mappings.value.ebs.volume_type
      }
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        delete_on_termination = block_device_mappings.value.ebs.delete_on_termination
        encrypted             = block_device_mappings.value.ebs.encrypted
        iops                  = block_device_mappings.value.ebs.iops
        throughput            = block_device_mappings.value.ebs.throughput
        volume_size           = block_device_mappings.value.ebs.volume_size
        volume_type           = block_device_mappings.value.ebs.volume_type
      }
    }
  }

  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags

  }

  monitoring {
    enabled = var.monitoring
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.sg_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { "Name" : local.lt_identifier })
  }
  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.tags, { "component" : "ebs" })
  }
  tag_specifications {
    resource_type = "network-interface"
    tags          = merge(local.tags, { "component" : "eni" })
  }
}
