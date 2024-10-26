# redshift:001: Use a custom admin username for Amazon Redshift clusters
# redshift:003: Enable encryption at rest for Amazon Redshift clusters using AWS KMS Customer Managed Keys (CMKs)
# redshift:004: Enable enhanced VPC routing for Amazon Redshift clusters
# redshift:005: Disable public accessibility for Amazon Redshift clusters
# redshift:006: Enable automatic version upgrades for Amazon Redshift clusters
# redshift:007: Enable Multi-AZ deployment for Amazon Redshift clusters
# redshift:008: Enforce SSL/TLS encryption for connections to Amazon Redshift clusters
# redshift:009: Enable automated snapshots for Amazon Redshift clusters
# redshift:010: Use a custom database name for Amazon Redshift clusters
resource "aws_redshift_cluster" "main" {
  cluster_identifier  = var.cluster_identifier
  database_name       = var.database_name
  master_username     = var.master_username
  master_password     = var.master_password
  node_type           = var.node_type
  cluster_type        = var.cluster_type
  number_of_nodes     = var.number_of_nodes

  encrypted           = true
  kms_key_id          = var.kms_key_id
  enhanced_vpc_routing = true
  publicly_accessible = false
  automated_snapshot_retention_period = var.snapshot_retention_period
  auto_upgrade        = true
  multi_az            = true

  vpc_security_group_ids = [var.security_group_id]
  cluster_subnet_group_name = var.subnet_group_name

  require_ssl = true
}

# redshift:002: Enable audit logging for Amazon Redshift clusters
resource "aws_redshift_cluster_parameter_group" "main" {
  family = "redshift-1.0"
  name   = "${var.cluster_identifier}-params"

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
}

# redshift:011: Encrypt Amazon Redshift snapshot copies using AWS KMS Customer Managed Keys (CMKs)
resource "aws_redshift_snapshot_copy_grant" "main" {
  snapshot_copy_grant_name = "${var.cluster_identifier}-snapshot-copy-grant"
  kms_key_id               = var.kms_key_id
}

# redshift:012: Encrypt Amazon Redshift Serverless namespaces using AWS KMS Customer Managed Keys (CMKs)
resource "aws_redshiftserverless_namespace" "main" {
  namespace_name      = var.serverless_namespace_name
  admin_username      = var.serverless_admin_username
  admin_user_password = var.serverless_admin_password
  db_name             = var.serverless_db_name
  kms_key_id          = var.kms_key_id
}

# redshift:013: Implement least privilege access for Amazon Redshift clusters
resource "aws_iam_role" "redshift_role" {
  name = "redshift_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftReadOnlyAccess"
  role       = aws_iam_role.redshift_role.name
}

# redshift:015: Enable Redshift query logging
resource "aws_redshift_event_subscription" "main" {
  name          = "${var.cluster_identifier}-query-logging"
  sns_topic_arn = var.sns_topic_arn
  source_type   = "cluster"
  source_ids    = [aws_redshift_cluster.main.id]
  event_categories = ["query"]
}