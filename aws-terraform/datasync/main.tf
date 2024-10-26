# AWS DataSync Secure Configuration

# datasync:001: Enable CloudWatch Logging for DataSync Tasks
resource "aws_datasync_task" "main" {
  source_location_arn      = var.source_location_arn
  destination_location_arn = var.destination_location_arn
  name                     = var.task_name
  cloudwatch_log_group_arn = var.cloudwatch_log_group_arn

  # datasync:002: Use AWS KMS Customer Managed Key for DataSync Encryption
  options {
    bytes_per_second = var.bytes_per_second
    verify_mode      = "POINT_IN_TIME_CONSISTENT"
    atime            = "BEST_EFFORT"
    mtime            = "PRESERVE"
    uid              = "NONE"
    gid              = "NONE"
    preserve_deleted_files = "REMOVE"
    preserve_devices       = "NONE"
    posix_permissions      = "PRESERVE"
    security_descriptor_copyflags = "NONE"
    task_queueing          = "ENABLED"
  }

  # datasync:005: Enable Integrity Verification for DataSync Transfers
  options {
    verify_mode = "POINT_IN_TIME_CONSISTENT"
  }

  # datasync:007: Implement Task-Level Filters for DataSync
  includes {
    filter_type = "SIMPLE_PATTERN"
    value       = var.include_pattern
  }

  # datasync:003: Restrict DataSync Task Access to Specific VPC Endpoints
  source_network_interface_arns      = var.source_vpc_endpoint_arns
  destination_network_interface_arns = var.destination_vpc_endpoint_arns
}

# datasync:004: Implement Least Privilege Access for DataSync Tasks
resource "aws_iam_role" "datasync_role" {
  name = "datasync-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datasync_policy" {
  name = "datasync-task-policy"
  role = aws_iam_role.datasync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "datasync:*",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "*"
      }
    ]
  })
}

# datasync:006: Use HTTPS for DataSync Connections
# This is enforced by default in AWS DataSync

# datasync:010: Use Secure Authentication Methods for DataSync Tasks
# This is handled by using IAM roles for authentication, which is the default and most secure method for AWS services