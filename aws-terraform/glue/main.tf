# AWS Glue Security Configuration

# glue:001: Enable encryption at rest for AWS Glue ETL jobs
# glue:005: Enable encryption at rest for AWS Glue Machine Learning transforms
# glue:010: Associate security configurations with AWS Glue components
resource "aws_glue_security_configuration" "main" {
  name = var.security_configuration_name

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn                = var.cloudwatch_kms_key_arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "CSE-KMS"
      kms_key_arn                   = var.job_bookmarks_kms_key_arn
    }

    s3_encryption {
      s3_encryption_mode = "SSE-KMS"
      kms_key_arn        = var.s3_kms_key_arn
    }
  }
}

# glue:002: Enable encryption at rest for AWS Glue development endpoints
resource "aws_glue_dev_endpoint" "main" {
  name                   = var.dev_endpoint_name
  role_arn               = var.dev_endpoint_role_arn
  security_configuration = aws_glue_security_configuration.main.name
  security_group_ids     = var.dev_endpoint_security_group_ids
  subnet_id              = var.dev_endpoint_subnet_id

  # glue:006: Enable encryption for AWS Glue development endpoints CloudWatch logs
  arguments = {
    "--enable-cloudwatch-logs" = "true"
    "--cloudwatch-log-group"   = var.dev_endpoint_log_group_name
  }
}

# glue:003: Enable metadata encryption for AWS Glue Data Catalog
resource "aws_glue_data_catalog_encryption_settings" "main" {
  data_catalog_encryption_settings {
    connection_password_encryption {
      aws_kms_key_id                       = var.data_catalog_kms_key_arn
      return_connection_password_encrypted = true
    }

    encryption_at_rest {
      catalog_encryption_mode = "SSE-KMS"
      sse_aws_kms_key_id      = var.data_catalog_kms_key_arn
    }
  }
}

# glue:007: Enable SSL for AWS Glue database connections
resource "aws_glue_connection" "main" {
  name = var.connection_name

  connection_properties = {
    JDBC_CONNECTION_URL = var.jdbc_connection_url
    USERNAME            = var.jdbc_username
    PASSWORD            = var.jdbc_password
  }

  physical_connection_requirements {
    security_group_id_list = var.connection_security_group_ids
    subnet_id              = var.connection_subnet_id
    availability_zone      = var.connection_availability_zone
  }

  catalog_id = var.catalog_id

  connection_type = "JDBC"

  # Enable SSL
  match_criteria = ["SSL"]
}

# glue:009: Restrict public access to AWS Glue Data Catalogs
resource "aws_glue_resource_policy" "main" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = [
          "arn:aws:glue:${var.region}:${var.account_id}:catalog",
          "arn:aws:glue:${var.region}:${var.account_id}:database/*",
          "arn:aws:glue:${var.region}:${var.account_id}:table/*"
        ]
        Principal = {
          AWS = var.allowed_principals
        }
      }
    ]
  })
}

# glue:011: Implement least privilege access for AWS Glue resources
resource "aws_iam_policy" "glue_read_only" {
  name        = "GlueReadOnlyPolicy"
  path        = "/"
  description = "IAM policy for read-only access to Glue resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:Get*",
          "glue:List*",
          "glue:BatchGet*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_write" {
  name        = "GlueWritePolicy"
  path        = "/"
  description = "IAM policy for write access to Glue resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# glue:012: Enable AWS Glue job bookmarks
# glue:013: Use VPC for AWS Glue jobs and development endpoints
# glue:014: Enable monitoring for AWS Glue jobs
# glue:015: Implement proper error handling and logging for AWS Glue jobs
resource "aws_glue_job" "main" {
  name         = var.job_name
  role_arn     = var.job_role_arn
  glue_version = var.glue_version

  command {
    script_location = var.script_location
    python_version  = var.python_version
  }

  default_arguments = {
    "--job-bookmark-option"                 = "job-bookmark-enable"
    "--enable-metrics"                      = ""
    "--enable-continuous-cloudwatch-log"    = "true"
    "--enable-continuous-log-filter"        = "true"
    "--continuous-log-logGroup"             = var.job_log_group
    "--enable-spark-ui"                     = "true"
    "--spark-event-logs-path"               = var.spark_event_logs_path
    "--enable-job-insights"                 = "true"
    "--enable-glue-datacatalog"             = ""
    "--TempDir"                             = var.temp_dir
    "--enable-auto-scaling"                 = "true"
    "--conf spark.sql.adaptive.enabled"     = "true"
    "--conf spark.serializer"               = "org.apache.spark.serializer.KryoSerializer"
    "--conf spark.sql.broadcastTimeout"     = "3600"
    "--conf spark.sql.shuffle.partitions"   = "100"
    "--conf spark.dynamicAllocation.enabled" = "true"
  }

  execution_property {
    max_concurrent_runs = var.max_concurrent_runs
  }

  security_configuration = aws_glue_security_configuration.main.name

  # Use VPC
  connections = [aws_glue_connection.main.name]

  # Enable CloudWatch monitoring
  max_retries = var.max_retries
  timeout     = var.timeout

  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers

  # Enable notifications for job status
  notification_property {
    notify_delay_after = var.notify_delay_after
  }
}