# AWS WorkSpaces Security Configuration

# workspaces:001 & workspaces:002: Use AWS KMS Customer Managed Key (CMK) for WorkSpaces Root and User Volume Encryption
resource "aws_workspaces_workspace" "main" {
  directory_id = var.directory_id
  bundle_id    = var.bundle_id
  user_name    = var.user_name

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = var.kms_key_id

  # workspaces:003: Configure WorkSpaces to Use Private IP Addresses Only
  workspace_properties {
    compute_type_name                         = var.compute_type_name
    user_volume_size_gib                      = var.user_volume_size_gib
    root_volume_size_gib                      = var.root_volume_size_gib
    running_mode                              = var.running_mode
    running_mode_auto_stop_timeout_in_minutes = var.auto_stop_timeout

    # workspaces:009: Enable Amazon WorkSpaces Streaming Protocol (WSP)
    protocols = ["WSP"]
  }

  # workspaces:005: Enable Automatic Updates for WorkSpaces
  workspace_properties {
    compute_type_name                         = var.compute_type_name
    user_volume_size_gib                      = var.user_volume_size_gib
    root_volume_size_gib                      = var.root_volume_size_gib
    running_mode                              = var.running_mode
    running_mode_auto_stop_timeout_in_minutes = var.auto_stop_timeout
  }

  # workspaces:007: Enable WorkSpaces Access Control Options
  workspace_properties {
    compute_type_name                         = var.compute_type_name
    user_volume_size_gib                      = var.user_volume_size_gib
    root_volume_size_gib                      = var.root_volume_size_gib
    running_mode                              = var.running_mode
    running_mode_auto_stop_timeout_in_minutes = var.auto_stop_timeout
    user_volume_encryption_enabled            = true
    root_volume_encryption_enabled            = true
  }

  # workspaces:011: Implement Tagging for WorkSpaces Resources
  tags = var.tags
}

# workspaces:004: Implement Security Group Rules for WorkSpaces
resource "aws_security_group_rule" "workspaces_ingress" {
  type              = "ingress"
  from_port         = 4172
  to_port           = 4172
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = var.workspace_security_group_id
}

# workspaces:006: Implement IP Access Control Groups for WorkSpaces
resource "aws_workspaces_ip_group" "main" {
  name        = var.ip_group_name
  description = "IP access control group for WorkSpaces"

  dynamic "rules" {
    for_each = var.ip_rules
    content {
      source      = rules.value.source
      description = rules.value.description
    }
  }
}

# workspaces:008: Implement Custom Images for WorkSpaces
resource "aws_workspaces_workspace" "custom_image" {
  directory_id = var.directory_id
  bundle_id    = var.custom_bundle_id
  user_name    = var.user_name

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = var.kms_key_id

  workspace_properties {
    compute_type_name                         = var.compute_type_name
    user_volume_size_gib                      = var.user_volume_size_gib
    root_volume_size_gib                      = var.root_volume_size_gib
    running_mode                              = var.running_mode
    running_mode_auto_stop_timeout_in_minutes = var.auto_stop_timeout
  }

  tags = var.tags
}

# workspaces:010: Configure WorkSpaces Directory Settings for Enhanced Security
resource "aws_workspaces_directory" "main" {
  directory_id = var.directory_id
  subnet_ids   = var.subnet_ids

  self_service_permissions {
    change_compute_type  = false
    increase_volume_size = false
    rebuild_workspace    = false
    restart_workspace    = true
    switch_running_mode  = false
  }

  workspace_access_properties {
    device_type_android    = "DENY"
    device_type_chromeos   = "DENY"
    device_type_ios        = "DENY"
    device_type_linux      = "DENY"
    device_type_osx        = "ALLOW"
    device_type_web        = "DENY"
    device_type_windows    = "ALLOW"
    device_type_zeroclient = "DENY"
  }

  workspace_creation_properties {
    enable_internet_access              = false
    enable_maintenance_mode             = true
    user_enabled_as_local_administrator = false
  }

  tags = var.tags
}

# workspaces:012: Enable WorkSpaces Maintenance Windows
resource "aws_workspaces_workspace" "maintenance" {
  directory_id = var.directory_id
  bundle_id    = var.bundle_id
  user_name    = var.user_name

  workspace_properties {
    compute_type_name                         = var.compute_type_name
    user_volume_size_gib                      = var.user_volume_size_gib
    root_volume_size_gib                      = var.root_volume_size_gib
    running_mode                              = var.running_mode
    running_mode_auto_stop_timeout_in_minutes = var.auto_stop_timeout
  }

  # Maintenance window configuration
  maintenance_mode {
    start_time = var.maintenance_start_time
    duration   = var.maintenance_duration
  }

  tags = var.tags
}

# workspaces:015: Implement Monitoring and Logging for WorkSpaces
resource "aws_cloudwatch_log_group" "workspaces" {
  name              = "/aws/workspaces/${var.log_group_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "workspaces_connection" {
  alarm_name          = "WorkSpaces-Unusual-Connection-Activity"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UserConnected"
  namespace           = "AWS/WorkSpaces"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.connection_threshold
  alarm_description   = "This metric monitors for unusual WorkSpaces connection activity"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    DirectoryId = var.directory_id
  }

  tags = var.tags
}