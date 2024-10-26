# AWS OpenSearch Domain Configuration

# opensearch:001: Enable Fine-Grained Access Control for OpenSearch Domains
# opensearch:002: Enable Encryption at Rest for OpenSearch Domains using AWS KMS
# opensearch:003: Enable Node-to-Node Encryption for OpenSearch Domains
# opensearch:004: Enable HTTPS for OpenSearch Domain Endpoints
# opensearch:005: Enable Audit Logging for OpenSearch Domains
# opensearch:006: Configure Three Dedicated Master Nodes for OpenSearch Domains
# opensearch:007: Enable Zone Awareness for OpenSearch Domains
# opensearch:008: Implement VPC-based Access Control for OpenSearch Domains
# opensearch:009: Enable Automated Snapshots for OpenSearch Domains
# opensearch:011: Enable UltraWarm and Cold Storage for OpenSearch Domains
# opensearch:012: Implement Cross-Cluster Search for OpenSearch Domains
# opensearch:013: Enable Custom Endpoint for OpenSearch Domains
# opensearch:015: Enable Slow Log Publishing for OpenSearch Domains
resource "aws_opensearch_domain" "main" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    dedicated_master_enabled = true
    dedicated_master_type  = var.dedicated_master_type
    dedicated_master_count = 3
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 3
    }

    warm_enabled = var.warm_enabled
    warm_type    = var.warm_type
    warm_count   = var.warm_count

    cold_storage_options {
      enabled = var.cold_storage_enabled
    }
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
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
    internal_user_database_enabled = var.internal_user_database_enabled
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    log_type                 = "AUDIT_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  auto_tune_options {
    desired_state = "ENABLED"
  }

  custom_endpoint {
    enabled     = true
    custom_endpoint = var.custom_endpoint
    custom_endpoint_certificate_arn = var.custom_endpoint_certificate_arn
  }
}

# opensearch:010: Implement IP-based Access Control for OpenSearch Domains
resource "aws_opensearch_domain_policy" "main" {
  domain_name = aws_opensearch_domain.main.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "es:*"
        Resource = "${aws_opensearch_domain.main.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ips
          }
        }
      }
    ]
  })
}

# opensearch:014: Implement Least Privilege Access for OpenSearch Domains
resource "aws_iam_policy" "opensearch_read_access" {
  name        = "${var.domain_name}-read-access"
  path        = "/"
  description = "IAM policy for read-only access to OpenSearch domain"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpGet",
          "es:ESHttpHead",
          "es:DescribeElasticsearchDomain",
          "es:ListTags"
        ]
        Resource = aws_opensearch_domain.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "opensearch_write_access" {
  name        = "${var.domain_name}-write-access"
  path        = "/"
  description = "IAM policy for write access to OpenSearch domain"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpGet",
          "es:ESHttpHead",
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpDelete",
          "es:DescribeElasticsearchDomain",
          "es:ListTags"
        ]
        Resource = aws_opensearch_domain.main.arn
      }
    ]
  })
}