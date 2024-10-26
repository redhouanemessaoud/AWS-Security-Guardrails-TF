# AWS Neptune Cluster Security Configuration

# neptune:001 - Enable CloudWatch audit logs for Neptune Clusters
# neptune:002 - Enable encryption at rest for Neptune Clusters using AWS KMS Customer Managed Keys (CMK)
# neptune:003 - Enable tag copying to snapshots for Neptune DB clusters
# neptune:004 - Enable encryption for Neptune DB cluster snapshots using AWS KMS Customer Managed Keys (CMK)
# neptune:005 - Configure appropriate backup retention period for Neptune Clusters
# neptune:006 - Enable IAM authentication for Neptune Clusters
# neptune:007 - Ensure Neptune Clusters are deployed in private subnets
# neptune:009 - Enable Multi-AZ deployment for Neptune Clusters
# neptune:010 - Enable deletion protection for Neptune Clusters
# neptune:011 - Configure secure TLS connections for Neptune Clusters
resource "aws_neptune_cluster" "main" {
  cluster_identifier                  = var.cluster_identifier
  engine                              = "neptune"
  engine_version                      = var.engine_version
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "${var.cluster_identifier}-final-snapshot"
  vpc_security_group_ids              = var.vpc_security_group_ids
  db_subnet_group_name                = var.db_subnet_group_name
  kms_key_arn                         = var.kms_key_arn
  storage_encrypted                   = true
  iam_database_authentication_enabled = true
  deletion_protection                 = true
  copy_tags_to_snapshot               = true
  snapshot_identifier                 = var.snapshot_identifier

  enabled_cloudwatch_logs_exports = ["audit"]

  availability_zones = var.availability_zones

  serverless_v2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  neptune_cluster_parameter_group_name = aws_neptune_cluster_parameter_group.main.name

  tags = var.tags
}

# neptune:011 - Configure secure TLS connections for Neptune Clusters
resource "aws_neptune_cluster_parameter_group" "main" {
  family = "neptune1"
  name   = "${var.cluster_identifier}-parameter-group"

  parameter {
    name  = "neptune_enforce_ssl"
    value = "1"
  }

  tags = var.tags
}

# neptune:013 - Enable VPC security group restrictions for Neptune Clusters
resource "aws_security_group_rule" "neptune_ingress" {
  type              = "ingress"
  from_port         = 8182
  to_port           = 8182
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = var.neptune_security_group_id
}

# neptune:012 - Implement least privilege access for Neptune Clusters
resource "aws_iam_role" "neptune_read_role" {
  name = "${var.cluster_identifier}-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "neptune_read_policy" {
  name = "${var.cluster_identifier}-read-policy"
  role = aws_iam_role.neptune_read_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "neptune-db:ReadDataViaQuery",
          "neptune-db:GetEngineStatus"
        ]
        Resource = aws_neptune_cluster.main.arn
      }
    ]
  })
}

resource "aws_iam_role" "neptune_write_role" {
  name = "${var.cluster_identifier}-write-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "neptune_write_policy" {
  name = "${var.cluster_identifier}-write-policy"
  role = aws_iam_role.neptune_write_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "neptune-db:ReadDataViaQuery",
          "neptune-db:WriteDataViaQuery",
          "neptune-db:DeleteDataViaQuery",
          "neptune-db:GetEngineStatus"
        ]
        Resource = aws_neptune_cluster.main.arn
      }
    ]
  })
}

# neptune:015 - Monitor Neptune Cluster performance and security metrics
resource "aws_cloudwatch_metric_alarm" "neptune_cpu_utilization" {
  alarm_name          = "${var.cluster_identifier}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/Neptune"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors Neptune cluster CPU utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    DBClusterIdentifier = aws_neptune_cluster.main.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "neptune_failed_logins" {
  alarm_name          = "${var.cluster_identifier}-failed-logins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "LoginFailures"
  namespace           = "AWS/Neptune"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.failed_login_threshold
  alarm_description   = "This metric monitors Neptune cluster failed login attempts"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    DBClusterIdentifier = aws_neptune_cluster.main.cluster_identifier
  }
}