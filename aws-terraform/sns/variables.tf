variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "https_endpoints" {
  description = "List of HTTPS endpoints to subscribe to the SNS topic"
  type        = list(string)
  default     = []
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "filtered_subscriptions" {
  description = "List of filtered subscriptions"
  type = list(object({
    protocol     = string
    endpoint     = string
    filter_policy = map(list(string))
  }))
  default = []
}

variable "enable_dlq" {
  description = "Enable Dead Letter Queue for the SNS topic"
  type        = bool
  default     = false
}

variable "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  type        = string
  default     = ""
}

variable "attribute_subscriptions" {
  description = "List of subscriptions with message attribute filtering"
  type = list(object({
    protocol     = string
    endpoint     = string
    filter_policy = map(list(string))
  }))
  default = []
}