variable "kms_key_id" {
  description = "The ARN of the KMS key to use for encryption"
  type        = string
}

variable "agent_role_arn" {
  description = "The ARN of the IAM role for the Bedrock agent"
  type        = string
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to access the Bedrock agent"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Number of days to retain Bedrock logs"
  type        = number
  default     = 90
}