# AWS AppFlow Secure Configuration

# appflow:001: Use AWS KMS Customer Managed Key (CMK) for AppFlow Connector Profile Encryption
# appflow:002: Use AWS KMS Customer Managed Key (CMK) for AppFlow Flow Encryption
resource "aws_appflow_connector_profile" "secure_profile" {
  name          = var.connector_profile_name
  connector_type = var.connector_type

  connection_mode = "Private"
  kms_arn         = var.kms_key_arn

  # Additional connector-specific configuration would go here
}

# appflow:002: Use AWS KMS Customer Managed Key (CMK) for AppFlow Flow Encryption
# appflow:003: Enable Encryption in Transit for AppFlow Flows
# appflow:005: Enable AppFlow Flow Logging
# appflow:006: Configure AppFlow Flow Failure Handling
# appflow:007: Implement Data Validation for AppFlow Flows
resource "aws_appflow_flow" "secure_flow" {
  name          = var.flow_name
  source_flow_config {
    connector_type = var.source_connector_type
    source_connector_properties {
      # Source connector specific configuration
    }
  }

  destination_flow_config {
    connector_type = var.destination_connector_type
    destination_connector_properties {
      # Destination connector specific configuration
    }
  }

  task {
    source_fields     = var.source_fields
    destination_field = var.destination_field
    task_type         = "Map"

    # appflow:007: Implement Data Validation for AppFlow Flows
    connector_operator {
      # Add data validation rules here
    }
  }

  trigger_config {
    trigger_type = var.trigger_type
    trigger_properties {
      # Trigger specific configuration
    }
  }

  # appflow:002: Use AWS KMS Customer Managed Key (CMK) for AppFlow Flow Encryption
  kms_arn = var.kms_key_arn

  # appflow:003: Enable Encryption in Transit for AppFlow Flows
  # AppFlow uses TLS 1.2 by default for data in transit

  # appflow:005: Enable AppFlow Flow Logging
  # appflow:006: Configure AppFlow Flow Failure Handling
  task_config {
    log_config {
      log_stream_arn = var.cloudwatch_log_stream_arn
    }
    error_handling_config {
      fail_on_first_destination_error = var.fail_on_first_destination_error
      bucket_prefix                   = var.error_handling_bucket_prefix
      bucket_name                     = var.error_handling_bucket_name
    }
  }

  # appflow:010: Enable AppFlow Tags for Resource Management
  tags = var.tags
}

# appflow:004: Implement Least Privilege Access for AppFlow Flows
resource "aws_iam_role" "appflow_role" {
  name = "appflow-least-privilege-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appflow.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "appflow_least_privilege" {
  name = "appflow-least-privilege-policy"
  role = aws_iam_role.appflow_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "appflow:DescribeFlow",
          "appflow:ListFlows",
          "appflow:StartFlow",
          "appflow:StopFlow",
          # Add other necessary permissions based on your specific use case
        ]
        Resource = aws_appflow_flow.secure_flow.arn
      }
    ]
  })
}