variable "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain log events in the log group"
  type        = number
  default     = 365
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encrypting log data"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "alarm_configurations" {
  description = "List of CloudWatch Alarm configurations"
  type = list(object({
    name                = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    description         = string
    alarm_actions       = list(string)
  }))
  default = []
}