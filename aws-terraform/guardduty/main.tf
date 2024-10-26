# AWS GuardDuty Secure Configuration

# guardduty:001: Enable AWS GuardDuty in all AWS regions
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
}

# guardduty:002: Enable GuardDuty Malware Protection for EC2 instances
resource "aws_guardduty_detector" "malware_protection" {
  enable = true
  datasources {
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
}

# guardduty:003: Enable GuardDuty S3 Protection
# guardduty:004: Enable GuardDuty RDS Protection
# guardduty:005: Enable GuardDuty EKS Audit Log Monitoring
# guardduty:006: Enable GuardDuty Lambda Protection
resource "aws_guardduty_detector" "additional_protections" {
  enable = true
  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
    rds_login_events {
      enable = true
    }
    lambda_network_logs {
      enable = true
    }
  }
}

# guardduty:007: Implement centralized management for GuardDuty
resource "aws_guardduty_organization_admin_account" "main" {
  admin_account_id = var.admin_account_id
}

# guardduty:008: Configure automated response for high severity GuardDuty findings
resource "aws_cloudwatch_event_rule" "guardduty_high_severity" {
  name        = "guardduty-high-severity-findings"
  description = "Capture high severity GuardDuty findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [7, 8, 9]
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_high_severity.name
  target_id = "SendToSNS"
  arn       = var.sns_topic_arn
}

# guardduty:009: Enable GuardDuty findings export to S3
resource "aws_guardduty_detector" "export_findings" {
  enable = true

  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = true
    }
  }
}

resource "aws_guardduty_publishing_destination" "s3_destination" {
  detector_id     = aws_guardduty_detector.export_findings.id
  destination_arn = var.findings_s3_bucket_arn
  kms_key_arn     = var.kms_key_arn

  destination_type = "S3"
}

# guardduty:010: Implement GuardDuty suppression rules
resource "aws_guardduty_filter" "example" {
  name        = "example_filter"
  action      = "ARCHIVE"
  detector_id = aws_guardduty_detector.main.id
  rank        = 1

  finding_criteria {
    criterion {
      field  = "severity"
      equals = ["1"]
    }
  }
}

# guardduty:011: Configure GuardDuty custom threat lists
resource "aws_guardduty_threatintelset" "example" {
  activate    = true
  detector_id = aws_guardduty_detector.main.id
  format      = "TXT"
  location    = var.threat_intel_set_location
  name        = "MyThreatIntelSet"
}

# guardduty:012: Enable GuardDuty integration with Security Hub
resource "aws_securityhub_product_subscription" "guardduty" {
  product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/guardduty"
}

# guardduty:014: Configure GuardDuty notifications
resource "aws_sns_topic" "guardduty_notifications" {
  name = "guardduty-notifications"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.guardduty_notifications.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.guardduty_notifications.arn,
    ]
  }
}

data "aws_region" "current" {}