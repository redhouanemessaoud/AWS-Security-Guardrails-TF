variable "kms_key_arn" {
  description = "ARN of the KMS key to use for EBS encryption"
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the AWS Backup vault to use for EBS backups"
  type        = string
}

variable "backup_role_arn" {
  description = "ARN of the IAM role to be used by AWS Backup"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "dlm_role_arn" {
  description = "ARN of the IAM role to be used by DLM for snapshot management"
  type        = string
}