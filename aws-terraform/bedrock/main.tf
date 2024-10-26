# Amazon Bedrock Security Configuration

# bedrock:001: Enable encryption for Amazon Bedrock model invocation logs using AWS KMS
# bedrock:003: Enable model invocation logging for Amazon Bedrock
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  kms_key_id = var.kms_key_id
  logging_enabled = true
}

# bedrock:002: Configure Prompt Attack Filter strength to HIGH for Amazon Bedrock Guardrails
# bedrock:004: Enable Sensitive Information Filters for Amazon Bedrock Guardrails
resource "aws_bedrock_custom_model_guardrails" "main" {
  name = "bedrock-guardrails"
  prompt_attack_filter_strength = "HIGH"
  sensitive_information_filter_enabled = true
}

# bedrock:005: Encrypt Amazon Bedrock Agent with AWS KMS Customer Managed Key
resource "aws_bedrock_agent" "main" {
  agent_name = "secure-bedrock-agent"
  agent_resource_role_arn = var.agent_role_arn
  instruction = "Secure Bedrock Agent"
  kms_key_arn = var.kms_key_id
}

# bedrock:006: Implement least privilege access for Amazon Bedrock resources
resource "aws_iam_policy" "bedrock_read" {
  name        = "bedrock-read-policy"
  path        = "/"
  description = "IAM policy for read-only access to Bedrock"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:GetFoundationModel",
          "bedrock:ListFoundationModels",
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "bedrock_write" {
  name        = "bedrock-write-policy"
  path        = "/"
  description = "IAM policy for write access to Bedrock"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:GetFoundationModel",
          "bedrock:ListFoundationModels",
          "bedrock:InvokeModel",
          "bedrock:CreateModelCustomization",
          "bedrock:DeleteModelCustomization",
          "bedrock:UpdateModelCustomization"
        ]
        Resource = "*"
      }
    ]
  })
}

# bedrock:008: Enable AWS KMS encryption for Amazon Bedrock data at rest
# This is implicitly handled by using KMS keys for agents and logging

# bedrock:009: Implement secure TLS configuration for Amazon Bedrock API calls
# This is handled by AWS automatically for Bedrock API calls

# bedrock:011: Implement resource-based policies for Amazon Bedrock resources
resource "aws_bedrock_resource_policy" "main" {
  resource_arn = aws_bedrock_agent.main.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_account_ids
        }
        Action   = ["bedrock:InvokeAgent"]
        Resource = aws_bedrock_agent.main.arn
      }
    ]
  })
}

# bedrock:013: Implement data retention policies for Amazon Bedrock logs and data
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_id
}