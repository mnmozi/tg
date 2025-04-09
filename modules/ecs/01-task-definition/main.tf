locals {
  region      = var.region
  environment = var.environment
  # service_name = "${var.required_tags.project}-${var.required_tags.component}"

  service_identifier              = (var.service_name == null || var.service_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.service_name
  iam_execution_role_identifier   = (var.iam_execution_role_name == null || var.iam_execution_role_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-execution" : var.iam_execution_role_name
  iam_execution_policy_identifier = (var.iam_execution_policy_identifier == null || var.iam_execution_policy_identifier == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-execution" : var.iam_execution_policy_identifier
  iam_task_role_identifier        = (var.iam_task_role_identifier == null || var.iam_task_role_identifier == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-task" : var.iam_task_role_identifier
  iam_task_policy_identifier      = (var.iam_task_policy_identifier == null || var.iam_task_policy_identifier == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-task" : var.iam_task_policy_identifier

  cpu    = sum(values(var.cpus))
  memory = sum(values(var.memories))
  secret_keys = {
    for container_name, secret_data in data.aws_secretsmanager_secret_version.service_secret :
    container_name => {
      keys       = keys(jsondecode(secret_data.secret_string))
      version_id = secret_data.version_id
    }
  }

  # Merge required tags with additional tags
  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_ecr_repository" "service_repo" {
  for_each = { for i, repo_name in tolist(var.images_repos) : i => repo_name }

  name = each.value
}

data "aws_ecr_image" "service_image" {
  for_each        = { for i, repo_name in tolist(var.images_repos) : i => repo_name }
  repository_name = each.value
  image_tag       = local.environment
}

data "aws_secretsmanager_secret_version" "service_secret" {
  for_each  = var.secrets_names
  secret_id = each.value
}


resource "aws_iam_policy" "execution_role_policy" {
  name        = local.iam_execution_policy_identifier
  description = "Execution role policy for ECS containers"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        (
          contains(values(var.log_drivers), "awslogs") ? {
            "Effect" : "Allow",
            "Action" : [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams",
              "logs:DescribeLogGroups"
            ],
            "Resource" : "*"
          } : null
        )
      ],
      [
        for secret in keys(data.aws_secretsmanager_secret_version.service_secret) : {
          "Effect" : "Allow",
          "Action" : ["secretsmanager:GetSecretValue"],
          "Resource" : data.aws_secretsmanager_secret_version.service_secret[secret].arn
        }
      ],
      var.custom_execution_statements
    )
  })
  tags = local.tags
}

resource "aws_iam_policy" "task_role_policy" {
  name        = local.iam_task_policy_identifier
  description = "Task role policy for ECS containers"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:DescribeLogGroups"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:DescribeInstanceInformation",
            "ssm:SendCommand",
            "ssm:StartSession",
            "ssm:DescribeSessions",
            "ssm:GetConnectionStatus",
            "ssmmessages:*",
            "ec2messages:*"
          ],
          "Resource" : "*"
        },
      ],
      [
        for secret in keys(data.aws_secretsmanager_secret_version.service_secret) : {
          "Effect" : "Allow",
          "Action" : ["secretsmanager:GetSecretValue"],
          "Resource" : data.aws_secretsmanager_secret_version.service_secret[secret].arn
        }
      ],
      var.custom_task_role_statements
    )
  })
  tags = local.tags
}

module "iam_execution_role" {
  source            = "/Users/mostafa.hamed/mycode/personal/terragrunt/modules/01-ami-role"
  name              = local.iam_execution_role_identifier
  is_instance       = false
  principal_service = ["ecs-tasks.amazonaws.com"]
  policies = merge(
    var.linked_execution_policies, {
      AmazonECSTaskExecutionRolePolicy = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
      customExecutionPolicy            = aws_iam_policy.execution_role_policy.arn
  })
  tags = local.tags
}


module "iam_task_role" {
  source            = "/Users/mostafa.hamed/mycode/personal/terragrunt/modules/01-ami-role"
  name              = local.iam_task_role_identifier
  is_instance       = false
  principal_service = ["ecs-tasks.amazonaws.com"]
  policies = merge(
    var.linked_task_policies, {
      customTaskPolicy = aws_iam_policy.task_role_policy.arn
  })
  tags = local.tags
}


resource "aws_ecs_task_definition" "service_task_definition" {
  family                   = local.service_identifier
  requires_compatibilities = var.requires_compatibilities
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory

  task_role_arn      = module.iam_task_role.aws_iam_role_arn
  execution_role_arn = module.iam_execution_role.aws_iam_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }

  container_definitions = jsonencode([
    for index, container_name in var.container_names : {
      name              = container_name
      image             = "${data.aws_ecr_repository.service_repo[index].repository_url}@${data.aws_ecr_image.service_image[index].image_digest}"
      cpu               = lookup(var.cpus, container_name, local.cpu / length(var.container_names))
      memoryReservation = lookup(var.memories, container_name, local.memory / length(var.container_names))
      essential         = true
      environment       = lookup(var.environment_variables, container_name, [])
      command           = lookup(var.commands, container_name, null)
      secrets = [
        for secret_key in local.secret_keys[container_name].keys : {
          name      = secret_key
          valueFrom = "${data.aws_secretsmanager_secret_version.service_secret[container_name].arn}:${secret_key}::${local.secret_keys[container_name].version_id}"
        }
      ]
      # secrets = length(lookup(var.secrets, container_name, [])) > 0 ? [
      #   for secret_name in lookup(var.secrets, container_name, []) : {
      #     name      = secret_name
      #     valueFrom = data.aws_secretsmanager_secret_version.service_secret[container_name].arn
      #   }
      # ] : null
      portMappings = contains(keys(var.containers_port), container_name) && contains(keys(var.hosts_port), container_name) ? [
        {
          containerPort = lookup(var.containers_port, container_name, null)
          hostPort      = lookup(var.hosts_port, container_name, null)
        }
      ] : null


      logConfiguration = merge(
        { logDriver = lookup(var.log_drivers, container_name, "awslogs") },
        lookup(
          {
            awslogs = {
              options = {
                "awslogs-group"         = container_name
                "awslogs-region"        = local.region
                "awslogs-create-group"  = "true"
                "awslogs-stream-prefix" = local.service_identifier
              }
            }
          },
          lookup(var.log_drivers, container_name, "awslogs"),
          {}
        )
      )
    }
  ])
  tags = local.tags
}

