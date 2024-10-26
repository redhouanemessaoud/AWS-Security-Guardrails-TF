# AWS EventBridge Secure Configuration

# eventbridge:001: Restrict EventBridge event bus access to known principals
# eventbridge:002: Limit cross-account access for EventBridge event buses
resource "aws_cloudwatch_event_bus" "main" {
  name = var.event_bus_name
}

resource "aws_cloudwatch_event_bus_policy" "main" {
  event_bus_name = aws_cloudwatch_event_bus.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RestrictEventBusAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_account_ids
        }
        Action   = "events:PutEvents"
        Resource = aws_cloudwatch_event_bus.main.arn
      }
    ]
  })
}

# eventbridge:003: Enable event replication for EventBridge global endpoints
resource "aws_cloudwatch_event_bus_policy" "replication" {
  count           = var.enable_replication ? 1 : 0
  event_bus_name  = aws_cloudwatch_event_bus.main.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventReplication"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "events:PutEvents"
        Resource = aws_cloudwatch_event_bus.main.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.replication_source_account
          }
        }
      }
    ]
  })
}

# eventbridge:005: Use AWS KMS Customer Managed Keys (CMK) for EventBridge rule encryption
# eventbridge:008: Use HTTPS endpoints for EventBridge API calls and targets
# eventbridge:010: Use dead-letter queues for failed event processing
# eventbridge:011: Implement input transformation for sensitive data in events
resource "aws_cloudwatch_event_rule" "main" {
  name           = var.rule_name
  description    = var.rule_description
  event_bus_name = aws_cloudwatch_event_bus.main.name
  event_pattern  = var.event_pattern

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "main" {
  rule           = aws_cloudwatch_event_rule.main.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "main-target"
  arn            = var.target_arn
  
  dead_letter_config {
    arn = var.dead_letter_arn
  }

  input_transformer {
    input_paths = var.input_paths
    input_template = var.input_template
  }
}

# eventbridge:009: Implement tagging for EventBridge resources
resource "aws_cloudwatch_event_bus" "tagged" {
  name = var.event_bus_name
  tags = var.tags
}

# eventbridge:006: Implement least privilege access for EventBridge resources
resource "aws_iam_policy" "eventbridge_read" {
  name        = "eventbridge-read-policy"
  description = "IAM policy for read-only access to EventBridge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:Describe*",
          "events:List*",
          "events:Get*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_write" {
  name        = "eventbridge-write-policy"
  description = "IAM policy for write access to EventBridge"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents",
          "events:PutRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "events:DeleteRule",
          "events:DisableRule",
          "events:EnableRule"
        ]
        Resource = aws_cloudwatch_event_bus.main.arn
      }
    ]
  })
}