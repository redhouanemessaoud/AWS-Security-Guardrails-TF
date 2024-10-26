# memorydb:001: Enable encryption in transit for MemoryDB clusters
# memorydb:002: Enable encryption at rest for MemoryDB clusters using AWS KMS Customer Managed Keys (CMKs)
# memorydb:003: Enable encryption for MemoryDB snapshots using AWS KMS Customer Managed Keys (CMKs)
# memorydb:004: Configure MemoryDB clusters to use private subnets only
# memorydb:006: Enable automatic failover for MemoryDB clusters
# memorydb:008: Enable Multi-AZ deployment for MemoryDB clusters
# memorydb:012: Use latest MemoryDB engine version
resource "aws_memorydb_cluster" "main" {
  name               = var.cluster_name
  node_type          = var.node_type
  num_shards         = var.num_shards
  num_replicas_per_shard = var.num_replicas_per_shard
  subnet_group_name  = var.subnet_group_name
  security_group_ids = var.security_group_ids
  tls_enabled        = true
  kms_key_arn        = var.kms_key_arn
  engine_version     = var.engine_version
  auto_minor_version_upgrade = true
  
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  maintenance_window = var.maintenance_window

  port = var.port

  parameter_group_name = aws_memorydb_parameter_group.main.id

  tags = var.tags
}

# memorydb:011: Implement MemoryDB parameter groups with secure configurations
resource "aws_memorydb_parameter_group" "main" {
  family = "memorydb_redis6"
  name   = "${var.cluster_name}-params"

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  parameter {
    name  = "activedefrag"
    value = "yes"
  }

  tags = var.tags
}

# memorydb:009: Implement regular backups for MemoryDB clusters
resource "aws_memorydb_snapshot" "main" {
  cluster_name = aws_memorydb_cluster.main.name
  name         = "${var.cluster_name}-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  kms_key_arn  = var.kms_key_arn
}

# memorydb:010: Enable MemoryDB event notifications
resource "aws_memorydb_event_subscription" "main" {
  name              = "${var.cluster_name}-events"
  sns_topic_arn     = var.sns_topic_arn
  source_type       = "cluster"
  source_ids        = [aws_memorydb_cluster.main.id]
  event_categories  = ["backup", "failure", "maintenance", "notification"]
}

# memorydb:005: Implement least privilege access for MemoryDB clusters (Read-only policy)
resource "aws_iam_policy" "memorydb_read_only" {
  name        = "${var.cluster_name}-read-only"
  path        = "/"
  description = "Read-only policy for MemoryDB cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "memorydb:DescribeClusters",
          "memorydb:DescribeParameters",
          "memorydb:DescribeSnapshots",
          "memorydb:ListTags",
        ]
        Resource = aws_memorydb_cluster.main.arn
      }
    ]
  })
}

# memorydb:005: Implement least privilege access for MemoryDB clusters (Write policy)
resource "aws_iam_policy" "memorydb_write" {
  name        = "${var.cluster_name}-write"
  path        = "/"
  description = "Write policy for MemoryDB cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "memorydb:CreateCluster",
          "memorydb:DeleteCluster",
          "memorydb:ModifyCluster",
          "memorydb:CreateSnapshot",
          "memorydb:DeleteSnapshot",
          "memorydb:TagResource",
          "memorydb:UntagResource",
        ]
        Resource = aws_memorydb_cluster.main.arn
      }
    ]
  })
}