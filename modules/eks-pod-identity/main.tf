# EKS Pod Identity: an IAM role a Kubernetes service account can assume.
#
# Why a local module instead of the shared tg.git policy-role module: that
# module's trust policy hardcodes only `sts:AssumeRole`. EKS Pod Identity also
# requires `sts:TagSession` (the pod-identity agent attaches session tags), and
# tg.git has no module for the aws_eks_pod_identity_association resource.

locals {
  tags = merge(
    var.required_tags,
    var.tags,
    { environment = var.environment },
  )
}

resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "pods.eks.amazonaws.com" }
        Action    = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = var.policy_arns
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# Customer-managed policies created from inline JSON, then attached to the
# role. Use this for workloads whose policy is published as a JSON file
# (e.g. AWS Load Balancer Controller) and not as an AWS-managed policy.
resource "aws_iam_policy" "inline" {
  for_each    = var.inline_policies
  name        = "${var.role_name}-${each.key}"
  description = "Inline policy '${each.key}' for ${var.role_name}"
  policy      = each.value
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "inline" {
  for_each   = aws_iam_policy.inline
  role       = aws_iam_role.this.name
  policy_arn = each.value.arn
}

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.this.arn
  tags            = local.tags
}
