# AWS MWAA Environment Configuration

# mwaa:001: Enable Scheduler Logs for MWAA Environment
# mwaa:002: Enable Webserver Logs for MWAA Environment
# mwaa:003: Enable Worker Logs for MWAA Environment
# mwaa:004: Enforce Private Network Access for MWAA Environment
# mwaa:005: Use AWS KMS Customer Managed Key for MWAA Environment Encryption
# mwaa:007: Enable MWAA Environment Monitoring with Amazon CloudWatch
# mwaa:008: Implement Secure Network Configuration for MWAA Environment
# mwaa:009: Enable Latest Apache Airflow Version for MWAA Environment
# mwaa:011: Enable MWAA Environment Tagging
resource "aws_mwaa_environment" "main" {
  name               = var.environment_name
  airflow_version    = var.airflow_version
  environment_class  = var.environment_class
  max_workers        = var.max_workers
  min_workers        = var.min_workers
  dag_s3_path        = var.dag_s3_path
  execution_role_arn = var.execution_role_arn
  source_bucket_arn  = var.source_bucket_arn

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  webserver_access_mode = "PRIVATE_ONLY"

  kms_key = var.kms_key_arn

  tags = var.tags
}

# mwaa:006: Implement Least Privilege IAM Roles for MWAA Environment
resource "aws_iam_role" "mwaa_execution" {
  name = "${var.environment_name}-mwaa-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "airflow.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mwaa_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonMWAAExecutionRolePolicy"
  role       = aws_iam_role.mwaa_execution.name
}

# mwaa:012: Implement Secure Secrets Management for MWAA Environment
resource "aws_secretsmanager_secret" "mwaa_secrets" {
  name        = "${var.environment_name}-mwaa-secrets"
  description = "Secrets for MWAA environment"
  kms_key_id  = var.kms_key_arn
}

# mwaa:014: Implement Secure DAG Deployment Process for MWAA Environment
resource "aws_s3_bucket_versioning" "dag_bucket_versioning" {
  bucket = var.dag_s3_bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# mwaa:015: Enable MWAA Environment Integration with AWS WAF
resource "aws_wafv2_web_acl_association" "mwaa_waf" {
  resource_arn = aws_mwaa_environment.main.webserver_url
  web_acl_arn  = var.waf_web_acl_arn
}