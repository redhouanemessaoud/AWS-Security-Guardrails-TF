# AWS Elasticsearch Domain Configuration

# elasticsearch:001: Enable encryption at rest using AWS KMS Customer Managed Key (CMK) for Elasticsearch domains
# elasticsearch:002: Enable node-to-node encryption for Elasticsearch domains
# elasticsearch:003: Enable fine-grained access control for Elasticsearch domains
# elasticsearch:004: Enable audit logging for Elasticsearch domains
# elasticsearch:005: Enforce HTTPS for all Elasticsearch domain endpoints
# elasticsearch:006: Configure Elasticsearch domains with at least three dedicated master nodes
# elasticsearch:007: Deploy Elasticsearch domains within a VPC
# elasticsearch:008: Use custom security groups for Elasticsearch domains
# elasticsearch:009: Use latest TLS policy for Elasticsearch domains
# elasticsearch:010: Enable error logging for Elasticsearch domains
# elasticsearch:011: Implement IP-based access control for Elasticsearch domains
# elasticsearch:012: Enable automated snapshots for Elasticsearch domains
# elasticsearch:014: Enable UltraWarm storage for Elasticsearch domains
# elasticsearch:015: Configure cross-cluster search for Elasticsearch domains
resource "aws_elasticsearch_domain" "main" {
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = true
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = 3
    zone_awareness_enabled   = true

    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
    volume_type = "gp2"
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = false
    master_user_options {
      master_user_arn = var.master_user_arn
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    log_type                 = "AUDIT_LOGS"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ultra_warm {
    enabled = true
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "es:*"
        Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ip_ranges
          }
        }
      }
    ]
  })

  tags = var.tags
}

# elasticsearch:015: Configure cross-cluster search for Elasticsearch domains
resource "aws_elasticsearch_outbound_cross_cluster_search_connection" "example" {
  count              = var.enable_cross_cluster_search ? 1 : 0
  domain_name        = aws_elasticsearch_domain.main.domain_name
  connection_alias   = var.cross_cluster_search_connection_alias
  target_domain_info {
    domain_name = var.target_domain_name
    endpoint    = var.target_domain_endpoint
    region      = var.target_domain_region
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}