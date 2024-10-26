variable "organization_id" {
  description = "The ID of the AWS Organization"
  type        = string
}

variable "allowed_regions" {
  description = "List of allowed AWS regions"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "config_aggregator_role_arn" {
  description = "The ARN of the IAM role for Config Aggregator"
  type        = string
}

variable "backup_role_arn" {
  description = "The ARN of the IAM role for AWS Backup"
  type        = string
}