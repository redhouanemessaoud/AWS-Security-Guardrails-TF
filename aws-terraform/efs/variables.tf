variable "private_subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "efs_security_group_id" {
  description = "ID of the security group for EFS mount targets"
  type        = string
}

variable "allowed_principal_arns" {
  description = "List of ARNs of IAM principals allowed to access the EFS file system"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for EFS encryption"
  type        = string
}

variable "creation_token" {
  description = "A unique name for the EFS file system"
  type        = string
}

variable "performance_mode" {
  description = "Performance mode for the EFS file system"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "Throughput mode for the EFS file system"
  type        = string
  default     = "bursting"
}

variable "transition_to_ia" {
  description = "Number of days after which to transition files to Infrequent Access storage class"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "posix_user_gid" {
  description = "POSIX group ID for access point"
  type        = number
}

variable "posix_user_uid" {
  description = "POSIX user ID for access point"
  type        = number
}

variable "root_directory_path" {
  description = "Path for the root directory of the access point"
  type        = string
  default     = "/efs"
}

variable "root_directory_owner_gid" {
  description = "POSIX group ID for the root directory of the access point"
  type        = number
}

variable "root_directory_owner_uid" {
  description = "POSIX user ID for the root directory of the access point"
  type        = number
}

variable "root_directory_permissions" {
  description = "POSIX permissions for the root directory of the access point"
  type        = string
  default     = "0755"
}

variable "burst_credit_balance_threshold" {
  description = "Threshold for EFS burst credit balance CloudWatch alarm"
  type        = number
  default     = 1000000000000
}

variable "percent_io_limit_threshold" {
  description = "Threshold for EFS percent I/O limit CloudWatch alarm"
  type        = number
  default     = 95
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}