resource "aws_iam_role" "ssm_customer_servers" {
  for_each = var.customers

  name = "ssm-onprem-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_role.ssm_managed_instance.arn
      }
    }]
  })
}

resource "aws_iam_role" "ssm_managed_instance" {
  name = "ssm-managed-onprem"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["ssm.amazonaws.com", "ec2.amazonaws.com"]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_managed_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ssm_customer_s3_ssm" {
  for_each = aws_iam_role.ssm_customer_servers

  name = "ssm-${each.key}"
  role = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = ["${aws_s3_bucket.shared_customer.arn}/tenants/${each.key}/*"]
      },
      {
        Effect = "Allow"
        Action = ["ssm:GetParameter*"],
        Resource = aws_ssm_parameter.cloudfront_private_key.arn
      }
    ]
  })
}
