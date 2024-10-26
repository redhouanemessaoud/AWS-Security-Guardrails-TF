variable "iam_users" {
  type        = list(string)
  description = "List of IAM users to create"
  default     = []
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of allowed IP ranges for IAM policy condition"
  default     = []
}

variable "trusted_account_id" {
  type        = string
  description = "AWS account ID trusted for cross-account access"
}

variable "external_id" {
  type        = string
  description = "External ID for cross-account role assumption"
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "CloudWatch Log Group name for IAM credential report monitoring"
}

variable "sns_topic_arn" {
  type        = string
  description = "SNS Topic ARN for IAM credential report alarm"
}

variable "saml_metadata_file" {
  type        = string
  description = "Path to SAML metadata file for federated access"
}