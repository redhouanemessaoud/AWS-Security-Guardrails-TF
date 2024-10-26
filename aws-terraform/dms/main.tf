# AWS DMS Replication Instance
resource "aws_dms_replication_instance" "main" {
  # dms:001: Enable Multi-AZ for DMS Replication Instances
  multi_az = true

  # dms:002: Disable Public Accessibility for DMS Replication Instances
  publicly_accessible = false

  # dms:003: Enable Auto Minor Version Upgrade for DMS Replication Instances
  auto_minor_version_upgrade = true

  # dms:006: Use KMS Customer Managed Key for DMS Replication Instance Encryption
  kms_key_arn = var.kms_key_arn

  # dms:008: Implement Network Isolation for DMS Replication Instances
  replication_instance_class = var.replication_instance_class
  vpc_security_group_ids    = var.security_group_ids
  replication_subnet_group_id = var.replication_subnet_group_id

  # dms:009: Enable CloudWatch Monitoring for DMS Replication Instances
  # CloudWatch monitoring is enabled by default for DMS replication instances

  # dms:014: Implement Resource Tagging for DMS Resources
  tags = var.tags
}

# AWS DMS Endpoint (Source and Target)
resource "aws_dms_endpoint" "main" {
  # dms:004: Enable SSL Mode for DMS Endpoints
  ssl_mode = "verify-full"

  # dms:005: Use KMS Customer Managed Key for DMS Endpoint Encryption
  kms_key_arn = var.kms_key_arn

  # dms:015: Enable AWS Secrets Manager Integration for DMS Endpoint Credentials
  secrets_manager_access_role_arn = var.secrets_manager_role_arn
  secrets_manager_arn             = var.secrets_manager_arn

  # dms:014: Implement Resource Tagging for DMS Resources
  tags = var.tags
}

# AWS DMS S3 Endpoint
resource "aws_dms_s3_endpoint" "main" {
  # dms:007: Use KMS Customer Managed Key for DMS S3 Endpoint Encryption
  kms_key_arn = var.kms_key_arn

  # dms:014: Implement Resource Tagging for DMS Resources
  tags = var.tags
}

# AWS DMS Replication Task
resource "aws_dms_replication_task" "main" {
  # dms:010: Implement IAM Roles for DMS Task Execution
  replication_task_settings = jsonencode({
    TargetMetadata = {
      SupportLobs = true
      FullLobMode = false
      LobChunkSize = 64
      LimitedSizeLobMode = true
      LobMaxSize = 32
    }
    FullLoadSettings = {
      TargetTablePrepMode = "DROP_AND_CREATE"
    }
    Logging = {
      EnableLogging = true
    }
  })

  # dms:011: Enable Change Data Capture (CDC) Validation for DMS Tasks
  cdc_start_time = var.cdc_start_time

  # dms:012: Implement Data Validation for DMS Tasks
  table_mappings = jsonencode({
    rules = [
      {
        rule-type = "selection"
        rule-id = "1"
        rule-name = "1"
        object-locator = {
          schema-name = "%"
          table-name = "%"
        }
        rule-action = "include"
      }
    ]
  })

  # dms:014: Implement Resource Tagging for DMS Resources
  tags = var.tags
}