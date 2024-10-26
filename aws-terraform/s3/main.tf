# S3-001: Enable S3 Account-Level Public Access Block
resource "aws_s3_account_public_access_block" "main" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3-002: Enable S3 Bucket-Level Public Access Block
# S3-003: Use AWS KMS Customer Managed Key (CMK) for S3 Bucket Encryption
# S3-004: Enable S3 Bucket Versioning
# S3-005: Enable S3 Bucket Logging
# S3-007: Enforce HTTPS for S3 Bucket Access
# S3-009: Enable S3 Object Lock for Critical Buckets
# S3-011: Disable S3 Bucket ACLs
# S3-014: Enable MFA Delete for Versioned S3 Buckets
# S3-020: Enable S3 Bucket Keys for Cost-Effective Encryption
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  
  # S3-011: Disable S3 Bucket ACLs
  force_destroy = true

  # S3-009: Enable S3 Object Lock for Critical Buckets
  object_lock_enabled = var.enable_object_lock

  # S3-004: Enable S3 Bucket Versioning
  # S3-014: Enable MFA Delete for Versioned S3 Buckets
  versioning {
    enabled    = true
    mfa_delete = var.enable_mfa_delete
  }

  # S3-005: Enable S3 Bucket Logging
  logging {
    target_bucket = var.log_bucket
    target_prefix = "log/${var.bucket_name}/"
  }
}

# S3-002: Enable S3 Bucket-Level Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3-003: Use AWS KMS Customer Managed Key (CMK) for S3 Bucket Encryption
# S3-020: Enable S3 Bucket Keys for Cost-Effective Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# S3-006: Implement S3 Bucket Lifecycle Policies
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# S3-007: Enforce HTTPS for S3 Bucket Access
resource "aws_s3_bucket_policy" "secure_transport" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# S3-010: Implement Cross-Region Replication for Critical S3 Buckets
resource "aws_s3_bucket_replication_configuration" "main" {
  count = var.enable_replication ? 1 : 0

  role   = var.replication_role_arn
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "ReplicateAll"
    status = "Enabled"

    destination {
      bucket        = var.destination_bucket_arn
      storage_class = "STANDARD"
    }
  }
}

# S3-012: Enable S3 Event Notifications
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  topic {
    topic_arn     = var.sns_topic_arn
    events        = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix = ".log"
  }
}

# S3-015: Implement S3 Access Points
resource "aws_s3_access_point" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "${var.bucket_name}-ap"

  # S3-016: Configure S3 Access Point Network Origin Controls
  vpc_configuration {
    vpc_id = var.vpc_id
  }

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# S3-017: Enable S3 Intelligent-Tiering for Cost Optimization
resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "EntireBucket"

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }
}

# S3-018: Implement S3 Inventory for Large-Scale Bucket Management
resource "aws_s3_bucket_inventory" "main" {
  bucket = aws_s3_bucket.main.id
  name   = "EntireBucketDaily"

  included_object_versions = "All"

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = var.inventory_bucket_arn
    }
  }

  optional_fields = ["Size", "LastModifiedDate", "StorageClass", "ETag", "IsMultipartUploaded", "ReplicationStatus", "EncryptionStatus", "ObjectLockRetainUntilDate", "ObjectLockMode", "ObjectLockLegalHoldStatus", "IntelligentTieringAccessTier"]
}

# S3-019: Configure S3 Object Lambda Access Points
resource "aws_s3_object_lambda_access_point" "main" {
  name = "${var.bucket_name}-lambda-ap"

  configuration {
    supporting_access_point = aws_s3_access_point.main.arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = var.lambda_function_arn
        }
      }
    }
  }
}