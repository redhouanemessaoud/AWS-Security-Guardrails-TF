# AWS Lambda Function Secure Configuration

# lambda:001: Use AWS KMS Customer Managed Key (CMK) for Lambda Function Environment Variables Encryption
# lambda:003: Use Only Supported and Non-Deprecated Lambda Function Runtimes
# lambda:004: Implement Dead Letter Queues for Lambda Functions
# lambda:005: Set Function-Level Concurrent Execution Limits for Lambda Functions
# lambda:006: Deploy Lambda Functions Within a VPC
# lambda:007: Enable X-Ray Tracing for Lambda Functions
# lambda:011: Deploy Lambda Functions Across Multiple Availability Zones
# lambda:013: Enable Enhanced Monitoring for Lambda Functions
resource "aws_lambda_function" "main" {
  filename         = var.lambda_filename
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.lambda_filename)

  environment {
    variables = var.environment_variables
  }

  kms_key_arn = var.kms_key_arn

  dead_letter_config {
    target_arn = var.dead_letter_queue_arn
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tracing_config {
    mode = "Active"
  }
}

# lambda:002: Enable Code Signing for Lambda Functions
resource "aws_lambda_code_signing_config" "main" {
  allowed_publishers {
    signing_profile_version_arns = var.signing_profile_version_arns
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

resource "aws_lambda_function_code_signing_config" "main" {
  code_signing_config_arn = aws_lambda_code_signing_config.main.arn
  function_name           = aws_lambda_function.main.function_name
}

# lambda:008: Secure Lambda Function URLs with Authentication
resource "aws_lambda_function_url" "main" {
  function_name      = aws_lambda_function.main.function_name
  authorization_type = "AWS_IAM"
}

# lambda:009: Restrict Lambda Function Resource-Based Policies
# lambda:010: Use SourceArn or SourceAccount in Lambda Function Permissions for AWS Services
resource "aws_lambda_permission" "main" {
  statement_id  = "AllowExecutionFromSpecificService"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = var.invoking_service_principal
  source_arn    = var.invoking_service_source_arn
}

# lambda:012: Implement Least Privilege IAM Roles for Lambda Functions
resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  policy_arn = aws_iam_policy.lambda_exec.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_policy" "lambda_exec" {
  name = "${var.function_name}-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

# lambda:015: Use AWS Secrets Manager for Storing Sensitive Information
resource "aws_secretsmanager_secret" "lambda_secrets" {
  name = "${var.function_name}-secrets"
}

resource "aws_secretsmanager_secret_version" "lambda_secrets" {
  secret_id     = aws_secretsmanager_secret.lambda_secrets.id
  secret_string = jsonencode(var.secrets)
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  policy_arn = aws_iam_policy.secrets_manager_access.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_policy" "secrets_manager_access" {
  name = "${var.function_name}-secrets-manager-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.lambda_secrets.arn
      }
    ]
  })
}