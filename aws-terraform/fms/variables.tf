variable "policy_name" {
  description = "The name of the AWS Firewall Manager policy"
  type        = string
}

variable "exclude_resource_tags" {
  description = "Whether to exclude resources with specified tags from the policy"
  type        = bool
  default     = false
}

variable "remediation_enabled" {
  description = "Whether automatic remediation is enabled"
  type        = bool
  default     = true
}

variable "resource_type" {
  description = "The type of resource protected by or in scope of the policy"
  type        = string
}

variable "security_service_policy_type" {
  description = "The type of security service policy"
  type        = string
}

variable "managed_service_data" {
  description = "Details about the service that are specific to the service type"
  type = object({
    type = string
    data = map(string)
  })
  default = null
}

variable "include_account_ids" {
  description = "List of AWS account IDs to include in the policy"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications"
  type        = string
  default     = null
}