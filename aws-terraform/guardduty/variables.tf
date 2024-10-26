variable "finding_publishing_frequency" {
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences."
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "admin_account_id" {
  description = "AWS account ID for centralized GuardDuty management"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for GuardDuty notifications"
  type        = string
}

variable "findings_s3_bucket_arn" {
  description = "ARN of the S3 bucket for exporting GuardDuty findings"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting GuardDuty findings"
  type        = string
}

variable "threat_intel_set_location" {
  description = "S3 URI of the custom threat intel set"
  type        = string
}