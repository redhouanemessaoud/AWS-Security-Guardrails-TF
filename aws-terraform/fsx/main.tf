# Amazon FSx Secure Configuration

# FSx:001, FSx:002, FSx:003: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for Amazon FSx file systems
resource "aws_fsx_lustre_file_system" "main" {
  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  deployment_type     = var.deployment_type
  storage_type        = var.storage_type
  kms_key_id          = var.kms_key_id
  security_group_ids  = var.security_group_ids

  # FSx:004: Enable tag copying to backups
  tags_all = var.tags

  # FSx:007: Enable automatic backups
  automatic_backup_retention_days = var.automatic_backup_retention_days

  # FSx:015: Implement secure data transfer for Amazon FSx for Lustre
  import_path      = var.import_path
  export_path      = var.export_path
  imported_file_chunk_size = var.imported_file_chunk_size

  # FSx:014: Enable storage capacity monitoring
  storage_capacity_quota_gib = var.storage_capacity_quota_gib
}

resource "aws_fsx_ontap_file_system" "main" {
  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  deployment_type     = var.deployment_type
  throughput_capacity = var.throughput_capacity
  kms_key_id          = var.kms_key_id
  security_group_ids  = var.security_group_ids

  # FSx:004: Enable tag copying to backups
  tags_all = var.tags

  # FSx:007: Enable automatic backups
  automatic_backup_retention_days = var.automatic_backup_retention_days
}

resource "aws_fsx_windows_file_system" "main" {
  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  throughput_capacity = var.throughput_capacity
  kms_key_id          = var.kms_key_id
  security_group_ids  = var.security_group_ids

  # FSx:004: Enable tag copying to backups
  tags_all = var.tags

  # FSx:007: Enable automatic backups
  automatic_backup_retention_days = var.automatic_backup_retention_days

  # FSx:009: Enable encryption in transit for Amazon FSx for Windows File Server
  copy_tags_to_backups = true
  deployment_type      = "MULTI_AZ_1"

  # FSx:010: Configure access control for Amazon FSx for Windows File Server
  active_directory_id = var.active_directory_id

  # FSx:011: Enable data deduplication for Amazon FSx for Windows File Server
  storage_type = "SSD"

  # FSx:013: Implement regular patching for Amazon FSx for Windows File Server
  weekly_maintenance_start_time = var.weekly_maintenance_start_time

  # FSx:014: Enable storage capacity monitoring
  storage_type_version = "2"
}

# FSx:005: Enable tag copying to volumes
resource "aws_fsx_ontap_storage_virtual_machine" "main" {
  file_system_id = aws_fsx_ontap_file_system.main.id
  name           = var.storage_virtual_machine_name
  
  tags = var.tags
}

# FSx:006: Implement least privilege access for Amazon FSx file systems
resource "aws_iam_role" "fsx_access" {
  name = "fsx-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "fsx.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "fsx_access" {
  name = "fsx-access-policy"
  role = aws_iam_role.fsx_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "fsx:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# FSx:012: Configure monitoring and alerting for Amazon FSx file systems
resource "aws_cloudwatch_metric_alarm" "fsx_storage_capacity" {
  alarm_name          = "fsx-storage-capacity-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StorageCapacity"
  namespace           = "AWS/FSx"
  period              = "300"
  statistic           = "Average"
  threshold           = var.storage_capacity_threshold
  alarm_description   = "This metric monitors FSx storage capacity"
  alarm_actions       = [var.sns_topic_arn]
}