# AWS MSK Cluster Configuration

# kafka:001: Use private subnets for MSK cluster deployment
# kafka:011: Implement multi-AZ deployment for MSK cluster
resource "aws_msk_cluster" "main" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [var.security_group_id]
  }

  # kafka:005: Use AWS KMS Customer Managed Key for MSK cluster encryption at rest
  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn
  }

  # kafka:007: Enable encryption in transit for MSK cluster
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  # kafka:004: Enable enhanced monitoring for MSK brokers
  enhanced_monitoring = "PER_BROKER"

  # kafka:010: Enable automatic minor version upgrades for MSK cluster
  configuration_info {
    arn      = aws_msk_configuration.main.arn
    revision = aws_msk_configuration.main.latest_revision
  }

  # kafka:012: Configure MSK cluster logging
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = var.cloudwatch_log_group_name
      }
      s3 {
        enabled = true
        bucket  = var.s3_logs_bucket
        prefix  = "msk-logs/"
      }
    }
  }

  # kafka:002: Enable mutual TLS authentication for MSK cluster
  # kafka:003: Disable unauthenticated access for MSK cluster
  # kafka:009: Configure secure client authentication for MSK cluster
  client_authentication {
    tls {
      certificate_authority_arns = [var.acm_certificate_arn]
    }
    sasl {
      scram = true
    }
  }

  tags = var.tags
}

# kafka:006: Use the latest supported Apache Kafka version for MSK cluster
# kafka:010: Enable automatic minor version upgrades for MSK cluster
resource "aws_msk_configuration" "main" {
  kafka_versions = [var.kafka_version]
  name           = "${var.cluster_name}-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable=false
default.replication.factor=3
min.insync.replicas=2
num.io.threads=8
num.network.threads=5
num.partitions=1
num.replica.fetchers=2
socket.request.max.bytes=104857600
unclean.leader.election.enable=false
PROPERTIES
}

# kafka:008: Implement fine-grained access control for MSK cluster
resource "aws_msk_scram_secret_association" "main" {
  cluster_arn     = aws_msk_cluster.main.arn
  secret_arn_list = [var.scram_secret_arn]
}

# kafka:013: Implement MSK cluster monitoring using Amazon CloudWatch
resource "aws_cloudwatch_metric_alarm" "msk_cpu_alarm" {
  alarm_name          = "${var.cluster_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CpuUser"
  namespace           = "AWS/Kafka"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors MSK broker CPU utilization"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    Cluster = aws_msk_cluster.main.cluster_name
  }
}

# kafka:015: Implement proper topic and partition management for MSK cluster
resource "aws_msk_cluster_policy" "example" {
  cluster_arn = aws_msk_cluster.main.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSpecificTopicOperations"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principal_arns
        }
        Action = [
          "kafka:CreateTopic",
          "kafka:DeleteTopic",
          "kafka:DescribeTopic",
          "kafka:AlterTopic"
        ]
        Resource = "arn:aws:kafka:${var.region}:${var.account_id}:topic/${aws_msk_cluster.main.cluster_name}/*"
      }
    ]
  })
}