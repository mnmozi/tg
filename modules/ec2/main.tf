locals {
  # Tagging and naming
  identifier = "${var.environment}-${var.required_tags.project}-${var.required_tags.component}"
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment, "Name" = local.identifier },
    var.owner != null ? { "owner" = var.owner } : {}
  )

  # Architecture mapping
  mapped_arch = lookup({
    "amazon-linux" = var.arch
    "ubuntu"       = var.arch == "x86_64" ? "amd64" : var.arch
  }, var.distro, null)

  # SSM path mapping
  ssm_path = lookup({
    "amazon-linux" = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-${local.mapped_arch}"
    "ubuntu"       = "/aws/service/canonical/ubuntu/server/24.04/stable/current/${local.mapped_arch}/hvm/ebs-gp3/ami-id"
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

data "aws_ami" "selected" {
  count = var.ami_inputs != null ? 1 : 0 # Create the block only if ami_name is set

  executable_users = var.ami_inputs.executable_users
  most_recent      = var.ami_inputs.most_recent
  owners           = var.ami_inputs.owners
  name_regex       = var.ami_inputs.ami_name # Directly use ami_name as regex

  dynamic "filter" {
    for_each = var.ami_inputs.filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

# Conditional creation of the IAM policy
resource "aws_iam_policy" "role_policy" {
  count = length(keys(data.aws_secretsmanager_secret_version.service_secret)) > 0 || length(var.custom_role_statements) > 0 ? 1 : 0

  name        = local.identifier
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
  tags = local.tags
}

# Module with conditional inclusion of custom_policy
module "role" {
  source            = "github.com/mnmozi/tg//modules/ami-role"
  name              = local.identifier
  is_instance       = true
  principal_service = ["ec2.amazonaws.com"]
  policies = merge(
    var.linked_policies, # Merge additional policies
    {
      amazon_ec2_rolefor_ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    },
    length(aws_iam_policy.role_policy) > 0 ? {
      custom_policy = aws_iam_policy.role_policy[0].arn
    } : {}
  )
  tags = local.tags
}

resource "aws_instance" "instance" {
  # ami = var.ami != null && var.ami != "" ? var.ami : data.aws_ssm_parameter.latest_ami[0].value
  ami = length(data.aws_ami.selected) > 0 ? data.aws_ami.selected[0].id : (var.ami != null && var.ami != "" ? var.ami : data.aws_ssm_parameter.latest_ami[0].value)

  instance_type                        = var.instance_type
  associate_public_ip_address          = var.associate_public_ip_address
  iam_instance_profile                 = module.role.aws_iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  key_name                             = var.key_name
  subnet_id                            = var.subnet_id

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

  metadata_options {
    http_tokens   = var.metadata.http_tokens
    http_endpoint = var.metadata.http_endpoint
  }
  root_block_device {
    delete_on_termination = var.root_block_device.delete_on_termination
    encrypted             = var.root_block_device.encrypted
    iops                  = var.root_block_device.iops
    throughput            = var.root_block_device.throughput
    volume_size           = var.root_block_device.volume_size
    volume_type           = var.root_block_device.volume_type
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      device_name           = ebs_block_device.value.device_name
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      throughput            = ebs_block_device.value.throughput
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      tags = merge(
        local.tags,
        { "Name" = ebs_block_device.value.name != "" ? ebs_block_device.value.name : "extra-${local.identifier}" }
      )
    }
  }

  vpc_security_group_ids = var.sg
  user_data              = var.user_data
  tags                   = local.tags
}
