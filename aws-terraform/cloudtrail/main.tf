# CloudTrail:001 Enable CloudTrail Insights for enhanced monitoring
resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_arn
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  # CloudTrail:002 Enable log file validation for CloudTrail
  # Implemented above with enable_log_file_validation = true

  # CloudTrail:003 Integrate CloudTrail with CloudWatch Logs
  cloud_watch_logs_group_arn = "${var.cloudwatch_log_group_arn}:*"
  cloud_watch_logs_role_arn  = var.cloudwatch_log_role_arn

  # CloudTrail:004 Encrypt CloudTrail log files at rest using KMS CMK
  # Implemented above with kms_key_id = var.kms_key_arn

  # CloudTrail:006 Configure CloudTrail to log data events for S3 buckets
  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  # CloudTrail:007 Enable CloudTrail multi-region logging
  # Implemented above with is_multi_region_trail = true

  # CloudTrail:008 Configure CloudTrail to use an SNS topic for notifications
  sns_topic_name = var.sns_topic_name

  tags = var.tags
}

# CloudTrail:005 Enable CloudTrail log file S3 bucket access logging
# Note: This is typically done on the S3 bucket itself, not in CloudTrail configuration

# CloudTrail:009 Use KMS CMK for CloudTrail Event Data Store encryption
resource "aws_cloudtrail_event_data_store" "main" {
  name        = var.event_data_store_name
  multi_region_enabled = true
  organization_enabled = true
  kms_key_id  = var.kms_key_arn
  retention_period = var.retention_period
  termination_protection_enabled = true

  tags = var.tags
}

# CloudTrail:010 Implement least privilege access for CloudTrail resources
# Note: This is a sample policy and should be adjusted based on specific needs
resource "aws_iam_policy" "cloudtrail_read_only" {
  name        = "cloudtrail-read-only"
  path        = "/"
  description = "Provides read-only access to CloudTrail"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:GetTrail",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:LookupEvents",
          "cloudtrail:ListTags",
          "cloudtrail:ListTrails",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_write" {
  name        = "cloudtrail-write"
  path        = "/"
  description = "Provides write access to CloudTrail"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:StartLogging",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "cloudtrail:DeleteTrail",
          "cloudtrail:CreateTrail",
          "cloudtrail:PutEventSelectors",
        ]
        Resource = "*"
      },
    ]
  })
}