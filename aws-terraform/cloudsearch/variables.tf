variable "domain_name" {
  description = "The name of the CloudSearch domain"
  type        = string
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to use for encryption at rest"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the CloudSearch domain VPC configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the CloudSearch domain VPC configuration"
  type        = list(string)
}

variable "allowed_aws_accounts" {
  description = "List of AWS account IDs allowed to access the CloudSearch domain"
  type        = list(string)
}

variable "search_latency_threshold" {
  description = "The threshold for search latency alarm (in seconds)"
  type        = number
  default     = 1
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms"
  type        = string
}