# AWS ElastiCache Redis Cluster

# elasticache:001: Enable Automatic Failover for ElastiCache Redis Clusters
# elasticache:003: Enable Automatic Backups for ElastiCache Redis Clusters
# elasticache:004: Enable Multi-AZ for ElastiCache Redis Clusters
# elasticache:005: Enable In-Transit Encryption for ElastiCache Redis Clusters
# elasticache:006: Enable At-Rest Encryption for ElastiCache Redis Clusters
# elasticache:008: Enable Automatic Minor Version Upgrades for ElastiCache Redis Clusters
# elasticache:010: Enable Auth Token for ElastiCache Redis Clusters
# elasticache:014: Use Latest ElastiCache Engine Version
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = var.replication_group_id
  description                = "Secured ElastiCache Redis cluster"
  node_type                  = var.node_type
  num_cache_clusters         = var.num_cache_clusters
  parameter_group_name       = var.parameter_group_name
  port                       = 6379
  automatic_failover_enabled = true
  multi_az_enabled           = true
  engine                     = "redis"
  engine_version             = var.engine_version
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = var.kms_key_id
  auth_token                 = var.auth_token
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  auto_minor_version_upgrade = true

  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [var.security_group_id]

  maintenance_window = var.maintenance_window
}

# elasticache:002: Use Private Subnets for ElastiCache Clusters
# elasticache:009: Use Custom Subnet Groups for ElastiCache Clusters
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.replication_group_id}-subnet-group"
  subnet_ids = var.subnet_ids
}

# elasticache:013: Enable ElastiCache Cluster Monitoring
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  alarm_name          = "${var.replication_group_id}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors ElastiCache CPU utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.id
  }
}

# elasticache:012: Implement Least Privilege Access for ElastiCache Clusters
resource "aws_iam_policy" "elasticache_read_only" {
  name        = "elasticache-read-only"
  path        = "/"
  description = "IAM policy for read-only access to ElastiCache"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticache:Describe*",
          "elasticache:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "elasticache_full_access" {
  name        = "elasticache-full-access"
  path        = "/"
  description = "IAM policy for full access to ElastiCache"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "elasticache:*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}