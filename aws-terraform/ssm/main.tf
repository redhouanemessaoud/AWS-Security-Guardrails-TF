# SSM:001 - Ensure SSM documents are not publicly accessible
resource "aws_ssm_document" "main" {
  name            = var.document_name
  document_type   = var.document_type
  content         = var.document_content
  document_format = var.document_format

  permissions = {
    type        = "Share"
    account_ids = var.allowed_account_ids
  }
}

# SSM:002 - Use AWS KMS Customer Managed Keys (CMK) for encrypting SSM parameters
# SSM:007 - Use secure string parameter type for sensitive data in SSM Parameter Store
resource "aws_ssm_parameter" "secure_parameter" {
  name        = var.parameter_name
  description = var.parameter_description
  type        = "SecureString"
  value       = var.parameter_value
  key_id      = var.kms_key_id
}

# SSM:003 - Enable encryption for Session Manager data in transit
# SSM:004 - Enable and encrypt Session Manager logs
resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = var.session_log_bucket_name
      s3KeyPrefix                 = var.session_log_key_prefix
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = var.session_log_group_name
      cloudWatchEncryptionEnabled = true
      kmsKeyId                    = var.session_encryption_key_id
      runAsEnabled                = true
      runAsDefaultUser            = ""
    }
  })
}

# SSM:008 - Implement version control for SSM documents
resource "aws_ssm_document" "versioned" {
  name            = var.versioned_document_name
  document_type   = var.versioned_document_type
  document_format = var.versioned_document_format
  content         = var.versioned_document_content
  version_name    = var.document_version
}

# SSM:010 - Implement resource tags for SSM managed instances
resource "aws_ssm_activation" "main" {
  name               = var.activation_name
  description        = var.activation_description
  iam_role           = var.activation_iam_role
  registration_limit = var.activation_registration_limit
  depends_on         = [aws_iam_role_policy_attachment.ssm_activation]

  tags = var.activation_tags
}

# SSM:011 - Enable SSM Inventory for managed instances
resource "aws_ssm_resource_data_sync" "inventory" {
  name = var.inventory_sync_name

  s3_destination {
    bucket_name = var.inventory_bucket_name
    prefix      = var.inventory_bucket_prefix
    region      = var.inventory_bucket_region
    kms_key_arn = var.inventory_kms_key_arn
  }
}

# SSM:012 - Implement SSM Patch Manager baseline with auto-approval rules
resource "aws_ssm_patch_baseline" "main" {
  name             = var.patch_baseline_name
  description      = var.patch_baseline_description
  operating_system = var.patch_baseline_os

  approval_rule {
    approve_after_days = var.patch_approval_delay
    compliance_level   = var.patch_compliance_level

    patch_filter {
      key    = "PRODUCT"
      values = var.patch_product_values
    }

    patch_filter {
      key    = "CLASSIFICATION"
      values = var.patch_classification_values
    }

    patch_filter {
      key    = "SEVERITY"
      values = var.patch_severity_values
    }
  }

  approved_patches                  = var.approved_patches
  approved_patches_comply_with_tags = var.approved_patches_comply_with_tags
  rejected_patches                  = var.rejected_patches
  rejected_patches_action           = var.rejected_patches_action
}

# SSM:015 - Implement SSM Parameter Store hierarchies for organized secret management
resource "aws_ssm_parameter" "hierarchical" {
  name        = "/${var.environment}/${var.application}/${var.parameter_name}"
  description = var.parameter_description
  type        = var.parameter_type
  value       = var.parameter_value
  key_id      = var.kms_key_id

  tags = var.parameter_tags
}