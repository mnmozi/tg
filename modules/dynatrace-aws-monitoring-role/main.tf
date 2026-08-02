# IAM role assumed by Dynatrace SaaS (Clouds app / da-aws extension) to pull
# AWS topology + CloudWatch metrics. Trust = Dynatrace's AWS account with the
# connection's settings objectId as external id (the tenant live-validates
# AssumeRole when the connection object is updated with this role's ARN).

variable "region" {
  type        = string
  description = "AWS region (IAM is global; used by the provider only)."
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "role_name" {
  type    = string
  default = "dev-dynatrace-aws-monitoring"
}

variable "dynatrace_principal" {
  type        = string
  default     = "arn:aws:iam::314146291599:root" # Dynatrace SaaS hyperscaler-connections account
  description = "AWS principal Dynatrace assumes the role from."
}

variable "external_id" {
  type        = string
  description = "The connection settings objectId from builtin:hyperscaler-authentication.connections.aws (not secret)."
}

variable "required_tags" {
  type = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.dynatrace_principal]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.external_id]
    }
  }
}

# ECS-focused read-only subset of Dynatrace's DynatraceMonitoringPolicy —
# enough for ECS topology + tags + CloudWatch metrics. Widen if more AWS
# services should show up in the Clouds app.
data "aws_iam_policy_document" "monitoring" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListClusters", "ecs:ListServices", "ecs:ListTasks",
      "ecs:ListTaskDefinitions", "ecs:ListContainerInstances",
      "ecs:ListAccountSettings", "ecs:ListTagsForResource",
      "ecs:DescribeClusters", "ecs:DescribeServices", "ecs:DescribeTasks",
      "ecs:DescribeTaskDefinition", "ecs:DescribeContainerInstances",
      "ecs:DescribeCapacityProviders",
      "tag:GetResources", "tag:GetTagKeys",
      "cloudwatch:GetMetricData", "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics",
      "ec2:DescribeAvailabilityZones", "ec2:DescribeRegions",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = merge(var.required_tags, var.tags)
}

resource "aws_iam_role_policy" "monitoring" {
  name   = "${var.role_name}-monitoring"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.monitoring.json
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}
