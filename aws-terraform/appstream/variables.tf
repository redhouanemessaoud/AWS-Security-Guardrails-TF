variable "fleet_name" {
  description = "Name of the AppStream 2.0 fleet"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the fleet"
  type        = string
}

variable "fleet_type" {
  description = "The fleet type (ALWAYS_ON or ON_DEMAND)"
  type        = string
  default     = "ON_DEMAND"
}

variable "max_user_duration_in_seconds" {
  description = "The maximum amount of time that a streaming session can remain active"
  type        = number
  default     = 36000 # 10 hours
}

variable "disconnect_timeout_in_seconds" {
  description = "The amount of time that a streaming session remains active after users disconnect"
  type        = number
  default     = 300 # 5 minutes
}

variable "idle_disconnect_timeout_in_seconds" {
  description = "The amount of time that users can be idle before they are disconnected"
  type        = number
  default     = 600 # 10 minutes
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for encryption"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the AppStream fleet"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the AppStream fleet"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "stack_name" {
  description = "Name of the AppStream 2.0 stack"
  type        = string
}

variable "stack_description" {
  description = "Description of the AppStream 2.0 stack"
  type        = string
  default     = "Managed by Terraform"
}

variable "stack_display_name" {
  description = "Display name of the AppStream 2.0 stack"
  type        = string
}

variable "home_folder_s3_arn" {
  description = "The ARN of the S3 bucket to use for home folders"
  type        = string
}

variable "usage_reports_s3_bucket_arn" {
  description = "The ARN of the S3 bucket to use for usage reports"
  type        = string
}

variable "user_name" {
  description = "The username for the AppStream 2.0 user"
  type        = string
}