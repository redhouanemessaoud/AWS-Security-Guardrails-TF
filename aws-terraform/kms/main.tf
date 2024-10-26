# AWS KMS Terraform Module

# KMS:001 Enable Key Rotation for Customer Managed Keys (CMK)
# KMS:002 Prevent Unintentional Deletion of KMS Keys
# KMS:007 Implement Multi-Region KMS Keys for Critical Data
resource "aws_kms_key" "main" {
  description             = var.key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.multi_region
  policy                  = var.key_policy

  tags = var.tags
}

# KMS:010 Implement KMS Key Aliases for Simplified Management
resource "aws_kms_alias" "main" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.main.key_id
}

# KMS:009 Enable Automatic Key Deletion for Imported Key Material
resource "aws_kms_external_key" "imported" {
  count                   = var.use_imported_key ? 1 : 0
  description             = "${var.key_description} (Imported)"
  deletion_window_in_days = var.deletion_window_in_days
  enabled                 = true
  key_material_base64     = var.imported_key_material
  valid_to                = var.imported_key_valid_to

  tags = var.tags
}

# KMS:004 Implement Least Privilege Access for KMS Keys
resource "aws_iam_policy" "kms_read" {
  name        = "${var.key_alias}-kms-read-policy"
  description = "Read-only policy for KMS key ${var.key_alias}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Describe*",
          "kms:Get*",
          "kms:List*"
        ]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}

resource "aws_iam_policy" "kms_write" {
  name        = "${var.key_alias}-kms-write-policy"
  description = "Write policy for KMS key ${var.key_alias}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ]
        Resource = aws_kms_key.main.arn
      }
    ]
  })
}