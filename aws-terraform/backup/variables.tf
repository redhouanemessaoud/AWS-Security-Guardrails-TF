variable "vault_name" {
  description = "Name of the AWS Backup vault"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encrypting backups"
  type        = string
}

variable "report_plan_name" {
  description = "Name of the AWS Backup report plan"
  type        = string
}

variable "report_bucket_name" {
  description = "Name of the S3 bucket to store backup reports"
  type        = string
}

variable "report_s3_key" {
  description = "S3 key prefix for backup reports"
  type        = string
  default     = "backup-reports/"
}

variable "backup_plan_name" {
  description = "Name of the AWS Backup plan"
  type        = string
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "cron(0 1 * * ? *)"  # Daily at 1 AM UTC
}

variable "retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "cross_region_vault_arn" {
  description = "ARN of the cross-region backup vault"
  type        = string
}

variable "backup_tags" {
  description = "Tags to apply to backup recovery points"
  type        = map(string)
  default     = {}
}

variable "ebs_volume_arns" {
  description = "List of EBS volume ARNs to include in the backup plan"
  type        = list(string)
  default     = []
}

variable "efs_filesystem_arns" {
  description = "List of EFS file system ARNs to include in the backup plan"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for backup notifications"
  type        = string
}