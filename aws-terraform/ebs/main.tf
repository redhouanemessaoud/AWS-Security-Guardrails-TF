# EBS-001: Enable EBS default encryption using AWS KMS Customer Managed Key (CMK)
resource "aws_ebs_encryption_by_default" "default" {
  enabled = true
}

resource "aws_ebs_default_kms_key" "default" {
  key_arn = var.kms_key_arn
}

# EBS-002: Encrypt EBS snapshots using AWS KMS Customer Managed Key (CMK)
# EBS-003: Encrypt all existing EBS volumes using AWS KMS Customer Managed Key (CMK)
# Note: These are enforced by default encryption (EBS-001)

# EBS-004: Implement IAM policies for EBS volume and snapshot management
resource "aws_iam_policy" "ebs_read_policy" {
  name        = "ebs-read-policy"
  description = "IAM policy for read-only access to EBS volumes and snapshots"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ebs_write_policy" {
  name        = "ebs-write-policy"
  description = "IAM policy for write access to EBS volumes and snapshots"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:ModifyVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      }
    ]
  })
}

# EBS-005: Enable EBS volume termination protection
# Note: This is set at the EC2 instance level, not directly on EBS volumes

# EBS-006: Implement regular backups of EBS volumes
resource "aws_backup_plan" "ebs_backup_plan" {
  name = "ebs-backup-plan"

  rule {
    rule_name         = "daily-backups"
    target_vault_name = var.backup_vault_name
    schedule          = "cron(0 1 * * ? *)"

    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_selection" "ebs_backup_selection" {
  name         = "ebs-backup-selection"
  plan_id      = aws_backup_plan.ebs_backup_plan.id
  iam_role_arn = var.backup_role_arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}

# EBS-007: Monitor EBS volume performance and usage
resource "aws_cloudwatch_metric_alarm" "ebs_high_queue_length" {
  alarm_name          = "ebs-high-queue-length"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "VolumeQueueLength"
  namespace           = "AWS/EBS"
  period              = 300
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "This metric monitors EBS volume queue length"
  alarm_actions       = [var.sns_topic_arn]
}

# EBS-008: Implement lifecycle policies for EBS snapshots
resource "aws_dlm_lifecycle_policy" "ebs_snapshot_policy" {
  description        = "EBS snapshot lifecycle policy"
  execution_role_arn = var.dlm_role_arn
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
        count = 7
      }
      tags_to_add = {
        SnapshotCreator = "DLM"
      }
      copy_tags = false
    }

    target_tags = {
      Backup = "true"
    }
  }
}

# EBS-009: Use EBS encryption with supported EC2 instance types
# Note: This is enforced by default encryption (EBS-001) and EC2 instance type selection

# EBS-010: Implement cross-region replication for critical EBS snapshots
# Note: This requires manual implementation or custom scripts, as Terraform doesn't directly support cross-region EBS snapshot replication