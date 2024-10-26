variable "directory_id" {
  description = "The ID of the directory for the WorkSpace"
  type        = string
}

variable "bundle_id" {
  description = "The ID of the bundle for the WorkSpace"
  type        = string
}

variable "user_name" {
  description = "The user name of the user for the WorkSpace"
  type        = string
}

variable "kms_key_id" {
  description = "The ARN of the KMS key used for encrypting WorkSpace volumes"
  type        = string
}

variable "compute_type_name" {
  description = "The compute type for the WorkSpace"
  type        = string
  default     = "STANDARD"
}

variable "user_volume_size_gib" {
  description = "The size of the user volume in GiB"
  type        = number
  default     = 50
}

variable "root_volume_size_gib" {
  description = "The size of the root volume in GiB"
  type        = number
  default     = 80
}

variable "running_mode" {
  description = "The running mode of the WorkSpace"
  type        = string
  default     = "AUTO_STOP"
}

variable "auto_stop_timeout" {
  description = "The time in minutes before the WorkSpace automatically stops in AUTO_STOP mode"
  type        = number
  default     = 60
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access WorkSpaces"
  type        = list(string)
}

variable "workspace_security_group_id" {
  description = "The ID of the security group for WorkSpaces"
  type        = string
}

variable "ip_group_name" {
  description = "The name of the IP access control group"
  type        = string
}

variable "ip_rules" {
  description = "List of IP rules for the access control group"
  type = list(object({
    source      = string
    description = string
  }))
}

variable "custom_bundle_id" {
  description = "The ID of the custom bundle for the WorkSpace"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs for the WorkSpaces directory"
  type        = list(string)
}

variable "maintenance_start_time" {
  description = "The start time for the maintenance window (e.g., 'Mon:02:00')"
  type        = string
}

variable "maintenance_duration" {
  description = "The duration of the maintenance window in hours"
  type        = string
  default     = "2"
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group for WorkSpaces"
  type        = string
}

variable "log_retention_days" {
  description = "The number of days to retain WorkSpaces logs"
  type        = number
  default     = 30
}

variable "connection_threshold" {
  description = "The threshold for unusual WorkSpaces connection activity"
  type        = number
  default     = 10
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for WorkSpaces alarms"
  type        = string
}