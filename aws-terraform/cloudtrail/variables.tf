variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting CloudTrail logs"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for CloudTrail logs"
  type        = string
}

variable "cloudwatch_log_role_arn" {
  description = "ARN of the IAM role for CloudTrail to CloudWatch logs integration"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for CloudTrail notifications"
  type        = string
}

variable "event_data_store_name" {
  description = "Name of the CloudTrail Event Data Store"
  type        = string
}

variable "retention_period" {
  description = "Retention period for CloudTrail Event Data Store in days"
  type        = number
  default     = 2555 # 7 years
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}