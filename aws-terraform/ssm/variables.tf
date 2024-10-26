variable "document_name" {
  description = "Name of the SSM document"
  type        = string
}

variable "document_type" {
  description = "Type of the SSM document"
  type        = string
  default     = "Command"
}

variable "document_content" {
  description = "Content of the SSM document"
  type        = string
}

variable "document_format" {
  description = "Format of the SSM document"
  type        = string
  default     = "YAML"
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to access the SSM document"
  type        = list(string)
  default     = []
}

variable "parameter_name" {
  description = "Name of the SSM parameter"
  type        = string
}

variable "parameter_description" {
  description = "Description of the SSM parameter"
  type        = string
  default     = ""
}

variable "parameter_value" {
  description = "Value of the SSM parameter"
  type        = string
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID for encrypting SSM parameters"
  type        = string
}

variable "session_log_bucket_name" {
  description = "Name of the S3 bucket for Session Manager logs"
  type        = string
}

variable "session_log_key_prefix" {
  description = "S3 key prefix for Session Manager logs"
  type        = string
  default     = "session-logs/"
}

variable "session_log_group_name" {
  description = "Name of the CloudWatch log group for Session Manager logs"
  type        = string
}

variable "session_encryption_key_id" {
  description = "KMS key ID for encrypting Session Manager data"
  type        = string
}

variable "versioned_document_name" {
  description = "Name of the versioned SSM document"
  type        = string
}

variable "versioned_document_type" {
  description = "Type of the versioned SSM document"
  type        = string
  default     = "Command"
}

variable "versioned_document_format" {
  description = "Format of the versioned SSM document"
  type        = string
  default     = "YAML"
}

variable "versioned_document_content" {
  description = "Content of the versioned SSM document"
  type        = string
}

variable "document_version" {
  description = "Version name for the SSM document"
  type        = string
}

variable "activation_name" {
  description = "Name of the SSM activation"
  type        = string
}

variable "activation_description" {
  description = "Description of the SSM activation"
  type        = string
  default     = ""
}

variable "activation_iam_role" {
  description = "IAM role for SSM activation"
  type        = string
}

variable "activation_registration_limit" {
  description = "Registration limit for SSM activation"
  type        = number
  default     = 5
}

variable "activation_tags" {
  description = "Tags for SSM activation"
  type        = map(string)
  default     = {}
}

variable "inventory_sync_name" {
  description = "Name of the SSM Inventory resource data sync"
  type        = string
}

variable "inventory_bucket_name" {
  description = "Name of the S3 bucket for SSM Inventory"
  type        = string
}

variable "inventory_bucket_prefix" {
  description = "S3 key prefix for SSM Inventory"
  type        = string
  default     = "inventory/"
}

variable "inventory_bucket_region" {
  description = "Region of the S3 bucket for SSM Inventory"
  type        = string
}

variable "inventory_kms_key_arn" {
  description = "ARN of the KMS key for encrypting SSM Inventory data"
  type        = string
}

variable "patch_baseline_name" {
  description = "Name of the SSM Patch Manager baseline"
  type        = string
}

variable "patch_baseline_description" {
  description = "Description of the SSM Patch Manager baseline"
  type        = string
  default     = ""
}

variable "patch_baseline_os" {
  description = "Operating system for the SSM Patch Manager baseline"
  type        = string
}

variable "patch_approval_delay" {
  description = "Number of days before patches are automatically approved"
  type        = number
  default     = 7
}

variable "patch_compliance_level" {
  description = "Compliance level for patches"
  type        = string
  default     = "CRITICAL"
}

variable "patch_product_values" {
  description = "List of product values for patch filter"
  type        = list(string)
  default     = ["*"]
}

variable "patch_classification_values" {
  description = "List of classification values for patch filter"
  type        = list(string)
  default     = ["SecurityUpdates", "CriticalUpdates"]
}

variable "patch_severity_values" {
  description = "List of severity values for patch filter"
  type        = list(string)
  default     = ["Critical", "Important"]
}

variable "approved_patches" {
  description = "List of explicitly approved patches"
  type        = list(string)
  default     = []
}

variable "approved_patches_comply_with_tags" {
  description = "Indicates whether approved patches comply with tags"
  type        = bool
  default     = true
}

variable "rejected_patches" {
  description = "List of explicitly rejected patches"
  type        = list(string)
  default     = []
}

variable "rejected_patches_action" {
  description = "Action to take on rejected patches"
  type        = string
  default     = "BLOCK"
}

variable "environment" {
  description = "Environment name for parameter hierarchy"
  type        = string
}

variable "application" {
  description = "Application name for parameter hierarchy"
  type        = string
}

variable "parameter_type" {
  description = "Type of the SSM parameter"
  type        = string
  default     = "SecureString"
}

variable "parameter_tags" {
  description = "Tags for the SSM parameter"
  type        = map(string)
  default     = {}
}