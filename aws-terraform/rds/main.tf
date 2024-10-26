# RDS Instance resource
resource "aws_db_instance" "main" {
  # rds:001: Enable Multi-AZ Deployment for RDS Instances
  multi_az = var.multi_az

  # rds:002: Use Supported and Up-to-Date RDS Engine Versions
  engine         = var.engine
  engine_version = var.engine_version

  # rds:004: Enable Automatic Minor Version Upgrades for RDS Instances and Clusters
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # rds:005: Enable CloudWatch Logs Integration for RDS Instances and Clusters
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # rds:006: Enable Encryption at Rest for RDS Instances and Clusters
  storage_encrypted = true
  kms_key_id        = var.kms_key_id

  # rds:007: Enable Copy Tags to Snapshots for RDS Instances and Clusters
  copy_tags_to_snapshot = true

  # rds:008: Use Non-Default Master Username for RDS Instances and Clusters
  username = var.master_username

  # rds:009: Enable IAM Database Authentication for RDS Instances and Clusters
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  # rds:012: Enable Enhanced Monitoring for RDS Instances
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # rds:013: Deploy RDS Instances within a VPC
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  # rds:014: Enable Deletion Protection for RDS Instances and Clusters
  deletion_protection = true

  # rds:016: Use Up-to-Date SSL/TLS Certificates for RDS Instances
  ca_cert_identifier = var.ca_cert_identifier

  # rds:017: Use Non-Default Ports for RDS Instances and Clusters
  port = var.db_port

  # rds:018: Enable Automatic Backups for RDS Instances
  backup_retention_period = var.backup_retention_period

  # rds:019: Enable Encryption in Transit for RDS Instances
  parameter_group_name = aws_db_parameter_group.main.name

  # rds:020: Enable Performance Insights with KMS Encryption for RDS Instances
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  performance_insights_retention_period = var.performance_insights_retention_period

  # Additional best practices
  publicly_accessible    = false
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.identifier}-final-snapshot"
  
  tags = var.tags
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.identifier}-param-group"
  family = var.parameter_group_family

  # rds:019: Enable Encryption in Transit for RDS Instances
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # rds:022: Enable Query Logging for PostgreSQL RDS Instances and Clusters
  dynamic "parameter" {
    for_each = var.engine == "postgres" ? [1] : []
    content {
      name  = "log_statement"
      value = "all"
    }
  }

  # rds:023: Enable Audit Logging for MySQL RDS Instances and Aurora MySQL Clusters
  dynamic "parameter" {
    for_each = var.engine == "mysql" ? [1] : []
    content {
      name  = "general_log"
      value = "1"
    }
  }

  tags = var.tags
}

# RDS Event Subscription
resource "aws_db_event_subscription" "main" {
  # rds:003: Enable Event Subscriptions for RDS Parameter Groups
  # rds:011: Enable Event Subscriptions for RDS Instances
  name      = "${var.identifier}-event-subscription"
  sns_topic = var.sns_topic_arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.main.id]

  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration",
  ]

  tags = var.tags
}

# IAM Policy for read-only access
data "aws_iam_policy_document" "read_only" {
  statement {
    actions = [
      "rds:Describe*",
      "rds:List*",
      "rds:Download*"
    ]
    resources = [aws_db_instance.main.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "read_only" {
  name        = "${var.identifier}-read-only-policy"
  path        = "/"
  description = "Read-only policy for RDS instance ${var.identifier}"
  policy      = data.aws_iam_policy_document.read_only.json
}

# IAM Policy for write access
data "aws_iam_policy_document" "write" {
  statement {
    actions = [
      "rds:Describe*",
      "rds:List*",
      "rds:Download*",
      "rds:Create*",
      "rds:Delete*",
      "rds:Modify*",
      "rds:Reboot*",
      "rds:RestoreDBInstanceFromDBSnapshot",
      "rds:RestoreDBInstanceToPointInTime"
    ]
    resources = [aws_db_instance.main.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "write" {
  name        = "${var.identifier}-write-policy"
  path        = "/"
  description = "Write policy for RDS instance ${var.identifier}"
  policy      = data.aws_iam_policy_document.write.json
}