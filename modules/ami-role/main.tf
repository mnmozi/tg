resource "aws_iam_role" "default" {
  name = var.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = var.principal_service
        },
        Effect = "Allow"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_instance_profile" "default" {
  count = var.is_instance ? 1 : 0
  name  = var.name
  role  = aws_iam_role.default.name

  depends_on = [aws_iam_role.default]
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each   = var.policies
  role       = aws_iam_role.default.name
  policy_arn = each.value
}
