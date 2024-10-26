# Main Terraform configuration for AWS Athena

# athena:001: Enable encryption at rest for Amazon Athena query results using AWS KMS Customer Managed Key (CMK)
# athena:006: Configure Athena workgroups with query result location encryption
resource "aws_athena_workgroup" "main" {
  name = var.workgroup_name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
      output_location = var.query_output_location
    }
  }

  # athena:002: Enforce workgroup configuration to prevent client-side overrides
  force_destroy = true

  # athena:007: Enable Athena query result reuse
  configuration {
    result_configuration {
      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }
    }
    engine_version {
      selected_engine_version = "Athena engine version 3"
    }
    query_execution_caching_mode = "ENABLED"
    query_execution_caching_ttl = var.query_result_reuse_ttl
  }

  # athena:009: Configure Athena workgroup query timeout
  configuration {
    query_timeout_in_seconds = var.query_timeout
  }
}

# athena:003: Enable logging for Amazon Athena workgroups
resource "aws_cloudwatch_log_group" "athena_logs" {
  name              = "/aws/athena/${var.workgroup_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.log_group_kms_key_arn
}

# athena:004: Use AWS KMS Customer Managed Key (CMK) for encrypting Athena databases
resource "aws_glue_catalog_database" "athena_database" {
  name = var.database_name
  catalog_id = var.catalog_id

  encryption_configuration {
    encryption_type = "SSE_KMS"
    kms_key_arn     = var.kms_key_arn
  }
}

# athena:005: Implement fine-grained access control for Athena resources
resource "aws_iam_policy" "athena_read_policy" {
  name        = "AthenaReadOnlyPolicy"
  path        = "/"
  description = "IAM policy for read-only access to Athena resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:GetWorkGroup",
          "athena:BatchGetQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:ListWorkGroups",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
          "athena:ListQueryExecutions",
          "athena:ListDatabases",
          "athena:GetDatabase",
          "athena:ListTableMetadata",
          "athena:GetTableMetadata"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "athena_write_policy" {
  name        = "AthenaWritePolicy"
  path        = "/"
  description = "IAM policy for write access to Athena resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:CreateWorkGroup",
          "athena:DeleteWorkGroup",
          "athena:UpdateWorkGroup",
          "athena:CreateNamedQuery",
          "athena:DeleteNamedQuery",
          "athena:CreatePreparedStatement",
          "athena:DeletePreparedStatement",
          "athena:UpdatePreparedStatement"
        ]
        Resource = "*"
      },
    ]
  })
}

# athena:008: Implement Athena prepared statements for security-sensitive queries
# This is more of a best practice for query writing and can't be directly implemented in Terraform

# athena:010: Use Athena federated query for secure access to diverse data sources
# This requires setting up data source connectors, which is typically done through the AWS console or CLI
# Terraform can be used to set up the necessary IAM roles and policies for the connectors
resource "aws_iam_role" "athena_federated_query" {
  name = "AtheneFederatedQueryRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "athena_federated_query" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
  role       = aws_iam_role.athena_federated_query.name
}