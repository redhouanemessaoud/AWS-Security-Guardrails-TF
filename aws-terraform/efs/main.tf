# EFS:001: Restrict EFS mount targets to private subnets
resource "aws_efs_mount_target" "private" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_security_group_id]
}

# EFS:002: Implement least privilege access for EFS file systems
# EFS:010: Implement IAM authentication for EFS file systems
resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceIAMAuthentication"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principal_arns
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_file_system.main.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "true"
          }
        }
      }
    ]
  })
}

# EFS:003: Enable encryption at rest for EFS file systems using AWS KMS CMK
# EFS:007: Enable encryption in transit for EFS file systems
# EFS:008: Implement lifecycle management for EFS file systems
# EFS:009: Enable performance mode and throughput mode for EFS file systems
resource "aws_efs_file_system" "main" {
  creation_token   = var.creation_token
  encrypted        = true
  kms_key_id       = var.kms_key_arn
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = var.tags
}

# EFS:004: Enforce user identity for EFS access points
# EFS:006: Enforce root directory for EFS access points
# EFS:011: Configure EFS access points with creation info
# EFS:015: Use EFS access points for application-specific entry points
resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  posix_user {
    gid = var.posix_user_gid
    uid = var.posix_user_uid
  }

  root_directory {
    path = var.root_directory_path
    creation_info {
      owner_gid   = var.root_directory_owner_gid
      owner_uid   = var.root_directory_owner_uid
      permissions = var.root_directory_permissions
    }
  }

  tags = var.tags
}

# EFS:005: Enable automatic backups for EFS file systems
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = "ENABLED"
  }
}

# EFS:013: Enable EFS file system monitoring with Amazon CloudWatch
resource "aws_cloudwatch_metric_alarm" "burst_credit_balance" {
  alarm_name          = "${var.creation_token}-burst-credit-balance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BurstCreditBalance"
  namespace           = "AWS/EFS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.burst_credit_balance_threshold
  alarm_description   = "This metric monitors EFS burst credit balance"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "percent_io_limit" {
  alarm_name          = "${var.creation_token}-percent-io-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "PercentIOLimit"
  namespace           = "AWS/EFS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.percent_io_limit_threshold
  alarm_description   = "This metric monitors EFS percent I/O limit"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }
}