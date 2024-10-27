variable "firewall_name" {
  description = "Name of the AWS Network Firewall"
  type        = string
}

variable "policy_name" {
  description = "Name of the AWS Network Firewall Policy"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the Network Firewall will be deployed"
  type        = string
}

variable "subnet_mappings" {
  description = "List of subnet IDs for Network Firewall deployment"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for Network Firewall logging"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Network Firewall logging"
  type        = string
}

variable "malicious_ip_ranges" {
  description = "List of IP ranges to be blocked"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}