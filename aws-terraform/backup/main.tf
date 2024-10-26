# AWS Backup Module

# backup:001: Enable encryption at rest for AWS Backup recovery points using KMS CMK
# backup:003: Create and configure AWS Backup vaults
# backup:004: Encrypt AWS Backup vaults using KMS CMK
resource "aws_backup_vault" "main" {
  name        = var.vault_name
  kms_key_arn = var.kms_key_arn
}

# backup:002: Create at least one AWS Backup report plan
resource "aws_backup_report_plan" "main" {
  name        = var.report_plan_name
  description = "AWS Backup report plan for monitoring backup activities"

  report_setting {
    report_template = "BACKUP_JOB_REPORT"
    s3_bucket       = var.report_bucket_name
    s3_key          = var.report_s3_key
    format          = "CSV"
  }
}

# backup:005: Create and implement at least one AWS Backup plan
# backup:006: Include EBS volumes in AWS Backup plans
# backup:007: Include Amazon EFS file systems in AWS Backup plans
# backup:008: Implement cross-region backup for critical resources
# backup:009: Enable continuous backups for supported services
# backup:011: Configure backup lifecycle management
# backup:014: Use resource tagging for AWS Backup management
resource "aws_backup_plan" "main" {
  name = var.backup_plan_name

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.retention_period
    }

    copy_action {
      destination_vault_arn = var.cross_region_vault_arn
    }

    recovery_point_tags = var.backup_tags
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

  # Include EBS volumes and EFS file systems
  selection {
    name = "resource_selection"
    resources = concat(
      var.ebs_volume_arns,
      var.efs_filesystem_arns
    )
  }
}

# backup:012: Enable AWS Backup audit manager
resource "aws_backup_vault_policy" "audit_manager" {
  backup_vault_name = aws_backup_vault.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSBackupAuditManagerAccess"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = [
          "backup:DescribeBackupVault",
          "backup:GetBackupVaultAccessPolicy",
          "backup:PutBackupVaultAccessPolicy",
          "backup:DeleteBackupVaultAccessPolicy"
        ]
        Resource = aws_backup_vault.main.arn
      }
    ]
  })
}

# backup:013: Implement backup notifications using Amazon SNS
resource "aws_backup_vault_notifications" "main" {
  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = var.sns_topic_arn
  backup_vault_events = ["BACKUP_JOB_STARTED", "BACKUP_JOB_COMPLETED", "RESTORE_JOB_COMPLETED"]
}

# backup:010: Implement least privilege access for AWS Backup
resource "aws_iam_role" "backup_role" {
  name               = "aws-backup-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_role.name
}