locals {
  region      = var.region
  environment = var.environment

  function_identifier    = (var.function_name == null || var.function_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}" : var.function_name
  iam_role_identifier    = (var.iam_role_name == null || var.iam_role_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-lambda" : var.iam_role_name
  iam_policy_identifier  = (var.iam_policy_name == null || var.iam_policy_name == "") ? "${var.environment}-${var.required_tags.project}-${var.required_tags.component}-lambda" : var.iam_policy_name

  tags = merge(
    var.required_tags,
    var.tags,
    { "environment" = var.environment },
    var.owner != null ? { "owner" = var.owner } : {}
  )
}

data "aws_secretsmanager_secret_version" "lambda_secret" {
  for_each  = var.secrets_names
  secret_id = each.value
}

resource "aws_iam_policy" "lambda_policy" {
  name        = local.iam_policy_identifier
  description = "Lambda execution policy for ${local.function_identifier}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ],
      var.vpc_subnet_ids != null ? [
        {
          Effect = "Allow"
          Action = [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
          ]
          Resource = "*"
        }
      ] : [],
      [
        for secret in keys(data.aws_secretsmanager_secret_version.lambda_secret) : {
          Effect   = "Allow"
          Action   = ["secretsmanager:GetSecretValue"]
          Resource = data.aws_secretsmanager_secret_version.lambda_secret[secret].arn
        }
      ],
      var.s3_bucket != null ? [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject"
          ]
          Resource = "arn:aws:s3:::${var.s3_bucket}/${var.s3_key}"
        }
      ] : [],
      var.custom_policy_statements
    )
  })
  tags = local.tags
}

module "iam_role" {
  source            = "github.com/mnmozi/tg//modules/ami-role"
  name              = local.iam_role_identifier
  is_instance       = false
  principal_service = ["lambda.amazonaws.com"]
  policies = merge(
    var.linked_policies, {
      customLambdaPolicy = aws_iam_policy.lambda_policy.arn
  })
  region = var.region
  tags   = local.tags
}

resource "aws_lambda_function" "this" {
  function_name = local.function_identifier
  role          = module.iam_role.aws_iam_role_arn

  runtime       = var.runtime
  handler       = var.handler
  architectures = [var.architecture]
  timeout       = var.timeout
  memory_size   = var.memory_size

  # Package type: Zip or Image
  package_type = var.package_type

  # For Zip deployments
  filename         = var.package_type == "Zip" ? var.filename : null
  source_code_hash = var.package_type == "Zip" ? var.source_code_hash : null
  s3_bucket        = var.package_type == "Zip" ? var.s3_bucket : null
  s3_key           = var.package_type == "Zip" ? var.s3_key : null

  # For Image deployments
  image_uri = var.package_type == "Image" ? var.image_uri : null

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish
  layers                         = var.layers

  tags = local.tags

  depends_on = [module.iam_role]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.function_identifier}"
  retention_in_days = var.log_retention_in_days
  tags              = local.tags
}

# EventBridge
resource "aws_cloudwatch_event_rule" "this" {
  for_each = var.eventbridge_rules

  name                = "${local.function_identifier}-${each.key}"
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
  event_pattern       = each.value.event_pattern
  state               = each.value.is_enabled ? "ENABLED" : "DISABLED"
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = var.eventbridge_rules

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "${local.function_identifier}-${each.key}"
  arn       = aws_lambda_function.this.arn
  input     = each.value.input
  input_path = each.value.input_path
}

resource "aws_lambda_permission" "eventbridge" {
  for_each = var.eventbridge_rules

  statement_id  = "AllowEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[each.key].arn
}
