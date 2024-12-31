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
  mapped_arch = lookup({
    "amazon-linux" = var.arch                                  # Amazon Linux uses x86_64 or arm64
    "ubuntu"       = var.arch == "x86_64" ? "amd64" : var.arch # Ubuntu uses amd64 for x86_64
  }, var.distro, null)

  # Map the SSM path for each distribution
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

resource "aws_iam_policy" "role_policy" {
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

module "role" {
  source            = "/Users/mostafa.hamed/mycode/personal/terragrunt/modules/01-ami-role"
  name              = local.identifier
  is_instance       = true
  principal_service = ["ec2.amazonaws.com"]
  policies = {
    amazon_ec2_rolefor_ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    custom_policy          = aws_iam_policy.role_policy.arn
  }
  tags = local.tags
}

resource "aws_instance" "instance" {
  ami = var.ami != null && var.ami != "" ? var.ami : data.aws_ssm_parameter.latest_ami[0].value

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
      tags                  = merge(local.tags, { "Name" = "extra-${local.identifier}" })
    }
  }

  vpc_security_group_ids = var.sg

  tags = local.tags
  # volume_tags = merge(local.tags, { "Name" = "volume-${local.identifier}" })
}
