# AWS Secrets Manager Terraform Module

# secretsmanager:001: Enable automatic rotation for Secrets Manager secrets
resource "aws_secretsmanager_secret_rotation" "main" {
  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

# secretsmanager:002: Use AWS KMS Customer Managed Keys (CMK) for Secrets Manager secret encryption
# secretsmanager:008: Enable and configure Secrets Manager secret versions
# secretsmanager:009: Implement tagging strategy for Secrets Manager secrets
resource "aws_secretsmanager_secret" "main" {
  name                    = var.secret_name
  description             = var.secret_description
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = var.tags
}

# secretsmanager:003: Implement resource-based policies to restrict access to Secrets Manager secrets
resource "aws_secretsmanager_secret_policy" "main" {
  secret_arn = aws_secretsmanager_secret.main.arn
  policy     = var.secret_policy
}

# secretsmanager:007: Implement strict IAM policies for Secrets Manager access
resource "aws_iam_policy" "secrets_manager_read" {
  name        = "secrets-manager-read-policy"
  path        = "/"
  description = "IAM policy for reading specific Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.main.arn
      },
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_write" {
  name        = "secrets-manager-write-policy"
  path        = "/"
  description = "IAM policy for writing to specific Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:RotateSecret"
        ]
        Resource = aws_secretsmanager_secret.main.arn
      },
    ]
  })
}

# secretsmanager:010: Use Secrets Manager for storing and rotating database credentials
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(var.db_credentials)
}