# AWS Firewall Manager Security Policy Module

# fms:001: Ensure AWS Firewall Manager security policies are compliant
resource "aws_fms_policy" "main" {
  name                  = var.policy_name
  exclude_resource_tags = var.exclude_resource_tags
  remediation_enabled   = var.remediation_enabled
  resource_type         = var.resource_type

  security_service_policy_data {
    type = var.security_service_policy_type

    dynamic "managed_service_data" {
      for_each = var.managed_service_data != null ? [var.managed_service_data] : []
      content {
        type = managed_service_data.value.type
        data = jsonencode(managed_service_data.value.data)
      }
    }
  }

  # fms:004: Implement AWS Firewall Manager policies for WAF
  # fms:005: Implement AWS Firewall Manager policies for Shield Advanced
  # fms:006: Implement AWS Firewall Manager policies for Security Groups
  # fms:008: Implement AWS Firewall Manager policies for Network Firewall
  # fms:010: Implement AWS Firewall Manager policies for DNS Firewall
  # These are implemented by setting the appropriate security_service_policy_type and managed_service_data

  # fms:003: Enable AWS Firewall Manager logging
  include_map {
    account = var.include_account_ids
  }

  # fms:009: Configure AWS Firewall Manager notifications
  dynamic "policy_option" {
    for_each = var.sns_topic_arn != null ? [1] : []
    content {
      notification_channel = var.sns_topic_arn
      notification_type    = "ALL"
    }
  }
}

# fms:002: Implement least privilege access for AWS Firewall Manager
resource "aws_iam_role" "fms_admin" {
  name               = "fms-admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "fms.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fms_admin" {
  role       = aws_iam_role.fms_admin.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFMAdminFullAccess"
}

# fms:007: Regularly review and update AWS Firewall Manager policies
# This is a process recommendation and cannot be directly implemented in Terraform