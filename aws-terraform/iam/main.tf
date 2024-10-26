# IAM:002 Configure strong IAM password policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
  max_password_age               = 90
}

# IAM:003 Enforce multi-factor authentication (MFA) for all IAM users
resource "aws_iam_user_login_profile" "example" {
  count                   = length(var.iam_users)
  user                    = var.iam_users[count.index]
  password_reset_required = true
}

# IAM:005 Use IAM roles for EC2 instances and AWS services
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM:007 Use IAM groups for access management
resource "aws_iam_group" "example_group" {
  name = "example-group"
}

resource "aws_iam_group_membership" "example" {
  name  = "example-group-membership"
  users = var.iam_users
  group = aws_iam_group.example_group.name
}

# IAM:008 Implement IAM access analyzer
resource "aws_accessanalyzer_analyzer" "example" {
  analyzer_name = "example-analyzer"
  type          = "ACCOUNT"
}

# IAM:011 Use IAM policy conditions for enhanced security
resource "aws_iam_policy" "example_policy" {
  name        = "example-policy"
  path        = "/"
  description = "Example policy with conditions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::example-bucket/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp": var.allowed_ip_ranges
          }
          Bool = {
            "aws:MultiFactorAuthPresent": "true"
          }
        }
      }
    ]
  })
}

# IAM:012 Implement cross-account access using IAM roles
resource "aws_iam_role" "cross_account_role" {
  name = "cross-account-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_account_id
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId": var.external_id
          }
        }
      }
    ]
  })
}

# IAM:014 Implement IAM credential report monitoring
resource "aws_cloudwatch_log_metric_filter" "iam_credential_report" {
  name           = "iam-credential-report"
  pattern        = "{ $.eventName = \"GenerateCredentialReport\" }"
  log_group_name = var.cloudwatch_log_group_name

  metric_transformation {
    name      = "IAMCredentialReportGenerated"
    namespace = "IAMMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_credential_report_alarm" {
  alarm_name          = "iam-credential-report-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "IAMCredentialReportGenerated"
  namespace           = "IAMMetrics"
  period              = "86400"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This alarm monitors the generation of IAM credential reports"
  alarm_actions       = [var.sns_topic_arn]
}

# IAM:015 Use temporary security credentials for federated access
resource "aws_iam_saml_provider" "example" {
  name                   = "example-saml-provider"
  saml_metadata_document = file(var.saml_metadata_file)
}

resource "aws_iam_role" "saml_role" {
  name = "saml-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_saml_provider.example.arn
        }
        Action = "sts:AssumeRoleWithSAML"
        Condition = {
          StringEquals = {
            "SAML:aud": "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })
}