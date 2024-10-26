# dlm:001: Define EBS Snapshot Lifecycle Policies
resource "aws_dlm_lifecycle_policy" "ebs_snapshot_policy" {
  description        = "EBS snapshot lifecycle policy"
  execution_role_arn = var.execution_role_arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = var.retention_count
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true
    }

    target_tags = var.target_tags
  }

  # dlm:002: Encrypt DLM Cross-Region Copy Events with AWS KMS Customer Managed Key
  # dlm:003: Encrypt DLM Cross-Region Copy Schedules with AWS KMS Customer Managed Key
  dynamic "cross_region_copy_rule" {
    for_each = var.cross_region_copy_rules
    content {
      target    = cross_region_copy_rule.value.target_region
      encrypted = true
      cmk_arn   = cross_region_copy_rule.value.cmk_arn
      retain_rule {
        interval      = cross_region_copy_rule.value.retain_interval
        interval_unit = "DAYS"
      }
    }
  }

  tags = var.tags
}

# dlm:005: Enable Retention of DLM Policy-Created Resources
# This is inherently implemented in the aws_dlm_lifecycle_policy resource above

# dlm:006: Use Tags for DLM Policy Resource Selection
# This is implemented in the target_tags variable used in the aws_dlm_lifecycle_policy resource above

# dlm:007: Implement Cross-Account Sharing for DLM Snapshots
resource "aws_dlm_lifecycle_policy" "cross_account_policy" {
  count               = var.enable_cross_account_sharing ? 1 : 0
  description         = "Cross-account snapshot sharing policy"
  execution_role_arn  = var.execution_role_arn
  state               = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily snapshots with cross-account sharing"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = var.retention_count
      }

      cross_region_copy_rule {
        target    = var.cross_account_target_region
        encrypted = true
        cmk_arn   = var.cross_account_cmk_arn
      }

      share_rule {
        target_accounts = var.cross_account_target_accounts
      }
    }

    target_tags = var.cross_account_target_tags
  }

  tags = var.tags
}

# dlm:008: Enable Fast Snapshot Restore for Critical Volumes
resource "aws_dlm_lifecycle_policy" "fast_restore_policy" {
  count               = var.enable_fast_snapshot_restore ? 1 : 0
  description         = "Fast Snapshot Restore policy for critical volumes"
  execution_role_arn  = var.execution_role_arn
  state               = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily snapshots with Fast Snapshot Restore"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = var.retention_count
      }

      fast_restore_rule {
        availability_zones = var.fast_restore_availability_zones
        count              = var.fast_restore_count
      }
    }

    target_tags = var.fast_restore_target_tags
  }

  tags = var.tags
}

# dlm:009: Implement Monitoring for DLM Policy Execution
resource "aws_cloudwatch_metric_alarm" "dlm_policy_failure_alarm" {
  alarm_name          = "DLM-Policy-Execution-Failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "PolicyExecutionFailureCount"
  namespace           = "AWS/DLM"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DLM policy execution failures"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    PolicyId = aws_dlm_lifecycle_policy.ebs_snapshot_policy.id
  }
}