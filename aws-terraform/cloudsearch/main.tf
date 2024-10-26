# CloudSearch Domain
resource "aws_cloudsearch_domain" "main" {
  name = var.domain_name

  # cloudsearch:003: Enable Encryption at Rest for CloudSearch Domain
  encryption_at_rest_options {
    enabled = true
    kms_key_id = var.kms_key_id
  }

  # cloudsearch:004: Implement VPC for CloudSearch Domain
  # cloudsearch:005: Restrict CloudSearch Domain Access to Specific VPC Endpoints
  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  # cloudsearch:001: Enforce HTTPS for CloudSearch Domain Access
  # cloudsearch:002: Use Latest TLS Version for CloudSearch Domain Connections
  endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # cloudsearch:009: Use Secure Configuration for CloudSearch Suggesters
  index_field {
    name            = "suggestion_field"
    type            = "text"
    analysis_scheme = "_en_default_"
    return          = true
    search          = true
    sort            = true
    highlight       = false
    suggester       = true
  }

  # cloudsearch:007: Enable CloudSearch Domain Monitoring with CloudWatch
  cloudwatch_logs_options {
    enabled = true
  }
}

# cloudsearch:010: Implement Access Policies for CloudSearch Document and Search Endpoints
resource "aws_cloudsearch_domain_service_access_policy" "main" {
  domain_name = aws_cloudsearch_domain.main.id

  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_aws_accounts
        }
        Action = [
          "cloudsearch:document",
          "cloudsearch:search"
        ]
        Resource = aws_cloudsearch_domain.main.arn
      }
    ]
  })
}

# cloudsearch:006: Implement IAM Policies for CloudSearch Domain Access
resource "aws_iam_policy" "cloudsearch_read" {
  name        = "${var.domain_name}-cloudsearch-read-policy"
  description = "IAM policy for read access to CloudSearch domain"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudsearch:DescribeDomains",
          "cloudsearch:DescribeIndexFields",
          "cloudsearch:Search",
          "cloudsearch:Suggest"
        ]
        Resource = aws_cloudsearch_domain.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "cloudsearch_write" {
  name        = "${var.domain_name}-cloudsearch-write-policy"
  description = "IAM policy for write access to CloudSearch domain"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudsearch:DescribeDomains",
          "cloudsearch:DescribeIndexFields",
          "cloudsearch:Search",
          "cloudsearch:Suggest",
          "cloudsearch:UpdateDomain",
          "cloudsearch:IndexDocuments"
        ]
        Resource = aws_cloudsearch_domain.main.arn
      }
    ]
  })
}

# cloudsearch:007: Enable CloudSearch Domain Monitoring with CloudWatch
resource "aws_cloudwatch_metric_alarm" "search_latency" {
  alarm_name          = "${var.domain_name}-search-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SearchLatency"
  namespace           = "AWS/CloudSearch"
  period              = "300"
  statistic           = "Average"
  threshold           = var.search_latency_threshold
  alarm_description   = "This metric monitors search latency for the CloudSearch domain"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    DomainName = aws_cloudsearch_domain.main.id
  }
}