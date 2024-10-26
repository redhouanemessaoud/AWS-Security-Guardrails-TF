# AWS DocumentDB Cluster Secure Configuration

# documentdb:001: Enable encryption at rest for DocumentDB clusters using AWS KMS Customer Managed Keys (CMK)
# documentdb:002: Enable automatic backups for DocumentDB clusters with adequate retention period
# documentdb:003: Disable public access for DocumentDB manual cluster snapshots
# documentdb:004: Enable log export feature for DocumentDB clusters
# documentdb:005: Enable deletion protection for DocumentDB clusters
# documentdb:006: Enable audit logging for DocumentDB clusters
# documentdb:007: Enforce TLS connections for DocumentDB clusters
# documentdb:008: Enable encryption at rest for DocumentDB global clusters
# documentdb:010: Enable enhanced monitoring for DocumentDB clusters
# documentdb:011: Use latest TLS version for DocumentDB connections
# documentdb:013: Restrict network access to DocumentDB clusters
# documentdb:014: Enable automatic minor version upgrades for DocumentDB clusters
resource "aws_docdb_cluster" "main" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "docdb"
  engine_version          = var.engine_version
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = var.apply_immediately
  deletion_protection     = var.deletion_protection

  storage_encrypted               = true
  kms_key_id                      = var.kms_key_id
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_ids             = var.subnet_ids

  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name

  tags = var.tags
}

resource "aws_docdb_cluster_parameter_group" "main" {
  family = "docdb4.0"
  name   = "${var.cluster_identifier}-params"

  parameter {
    name  = "tls"
    value = "enabled"
  }

  parameter {
    name  = "audit_logs"
    value = "enabled"
  }

  parameter {
    name  = "ttl_monitor"
    value = "enabled"
  }

  tags = var.tags
}

# documentdb:010: Enable enhanced monitoring for DocumentDB clusters
resource "aws_docdb_cluster_instance" "main" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  monitoring_interval        = var.monitoring_interval
  monitoring_role_arn        = var.monitoring_role_arn

  tags = var.tags
}

# documentdb:009: Implement least privilege access for DocumentDB clusters
resource "aws_iam_policy" "docdb_read_only" {
  name        = "${var.cluster_identifier}-read-only-policy"
  description = "Read-only policy for DocumentDB cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource"
        ]
        Resource = aws_docdb_cluster.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "docdb_write" {
  name        = "${var.cluster_identifier}-write-policy"
  description = "Write policy for DocumentDB cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:ModifyDBCluster",
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance"
        ]
        Resource = aws_docdb_cluster.main.arn
      }
    ]
  })
}