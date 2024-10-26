variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "enable_object_lock" {
  description = "Enable S3 object lock"
  type        = bool
  default     = true
}

variable "enable_mfa_delete" {
  description = "Enable MFA delete for versioned bucket"
  type        = bool
  default     = true
}

variable "log_bucket" {
  description = "Name of the bucket to store access logs"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "enable_replication" {
  description = "Enable cross-region replication"
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "ARN of the IAM role for replication"
  type        = string
  default     = ""
}

variable "destination_bucket_arn" {
  description = "ARN of the destination bucket for replication"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for event notifications"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC for access point"
  type        = string
}

variable "inventory_bucket_arn" {
  description = "ARN of the bucket to store inventory reports"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function for Object Lambda Access Point"
  type        = string
}