# mskcluster:001: Use AWS KMS Customer Managed Key (CMK) for MSK Cluster Encryption at Rest
# mskcluster:002: Enable TLS Encryption for MSK Cluster Data in Transit
# mskcluster:003: Enable Logging for MSK Cluster
# mskcluster:004: Deploy MSK Cluster in Private Subnets
# mskcluster:005: Implement Fine-Grained Access Control for MSK Cluster
# mskcluster:006: Configure Security Groups for MSK Cluster
# mskcluster:007: Enable Enhanced Monitoring for MSK Cluster
# mskcluster:008: Implement MSK Cluster Multi-AZ Deployment
# mskcluster:009: Enable Automatic Version Upgrades for MSK Cluster
# mskcluster:010: Implement MSK Cluster Scaling and Rightsizing
# mskcluster:011: Enable MSK Cluster Monitoring with Prometheus
# mskcluster:012: Implement Secure Client Authentication for MSK Cluster
# mskcluster:013: Enable MSK Cluster Configuration History
# mskcluster:015: Use Custom Configuration for MSK Cluster
resource "aws_msk_cluster" "main" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.client_subnets
    security_groups = var.security_group_ids

    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = var.cloudwatch_log_group
      }
      s3 {
        enabled = true
        bucket  = var.s3_logs_bucket
        prefix  = "msk-logs/"
      }
    }
  }

  enhanced_monitoring = "PER_BROKER"

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.custom.arn
    revision = aws_msk_configuration.custom.latest_revision
  }

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

resource "aws_msk_configuration" "custom" {
  name              = "${var.cluster_name}-custom-config"
  kafka_versions    = [var.kafka_version]
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

resource "aws_msk_scram_secret_association" "main" {
  cluster_arn     = aws_msk_cluster.main.arn
  secret_arn_list = var.scram_secret_arns
}