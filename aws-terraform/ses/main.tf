# AWS SES Security Configuration

# ses:001: Restrict SES identity access to known principals or accounts
resource "aws_ses_identity_policy" "restricted_access" {
  count    = var.enable_ses_identity_policy ? 1 : 0
  identity = var.ses_identity_arn
  name     = "restricted_access_policy"
  policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principals
        }
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = var.ses_identity_arn
      }
    ]
  })
}

# ses:002: Enforce TLS for SES Configuration Sets
resource "aws_ses_configuration_set" "tls_enforced" {
  name = var.configuration_set_name

  delivery_options {
    tls_policy = "Require"
  }
}

# ses:003: Enable DKIM signing for SES identities
resource "aws_ses_domain_dkim" "main" {
  domain = var.domain_name
}

# ses:005: Enable SES event publishing to CloudWatch
resource "aws_ses_event_destination" "cloudwatch" {
  name                   = "cloudwatch-event-destination"
  configuration_set_name = aws_ses_configuration_set.tls_enforced.name
  enabled                = true
  matching_types         = ["send", "reject", "bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "ses_events"
    value_source   = "messageTag"
  }
}

# ses:007: Use SES API v2 for enhanced security features
# Note: This is a best practice recommendation and doesn't require a specific Terraform resource

# ses:008: Implement SES sending authorization policies
resource "aws_ses_identity_policy" "sending_authorization" {
  count    = var.enable_sending_authorization ? 1 : 0
  identity = var.ses_identity_arn
  name     = "sending_authorization_policy"
  policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.authorized_senders
        }
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = var.ses_identity_arn
      }
    ]
  })
}

# ses:009: Enable SES feedback notifications
resource "aws_ses_identity_notification_topic" "main" {
  for_each        = toset(["bounce", "complaint", "delivery"])
  identity        = var.ses_identity_arn
  notification_type = each.key
  topic_arn       = var.sns_topic_arn
  include_original_headers = true
}

# ses:010: Implement SES content filtering
resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "content-filtering-rule-set"
}

resource "aws_ses_receipt_rule" "content_filter" {
  name          = "content-filter-rule"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = ["*"]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = var.s3_bucket_name
    position    = 1
  }
}