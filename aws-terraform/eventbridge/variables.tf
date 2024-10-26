variable "event_bus_name" {
  description = "Name of the EventBridge event bus"
  type        = string
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to put events on the event bus"
  type        = list(string)
}

variable "enable_replication" {
  description = "Enable event replication for global endpoints"
  type        = bool
  default     = false
}

variable "replication_source_account" {
  description = "AWS account ID of the replication source"
  type        = string
  default     = ""
}

variable "rule_name" {
  description = "Name of the EventBridge rule"
  type        = string
}

variable "rule_description" {
  description = "Description of the EventBridge rule"
  type        = string
}

variable "event_pattern" {
  description = "Event pattern for the rule"
  type        = string
}

variable "target_arn" {
  description = "ARN of the target for the rule"
  type        = string
}

variable "dead_letter_arn" {
  description = "ARN of the dead letter queue for failed event processing"
  type        = string
}

variable "input_paths" {
  description = "Map of key-value pairs for input transformation"
  type        = map(string)
  default     = {}
}

variable "input_template" {
  description = "Input template for transformation"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to EventBridge resources"
  type        = map(string)
  default     = {}
}