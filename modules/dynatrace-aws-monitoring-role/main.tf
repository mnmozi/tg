# IAM role assumed by Dynatrace SaaS (Clouds app / da-aws extension) to pull
# AWS topology + CloudWatch metrics. Trust = Dynatrace's AWS account with the
# connection's settings objectId as external id (the tenant live-validates
# AssumeRole when the connection object is updated with this role's ARN).

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
