variable "connector_profile_name" {
  description = "Name of the AppFlow connector profile"
  type        = string
}

variable "connector_type" {
  description = "Type of the AppFlow connector"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "flow_name" {
  description = "Name of the AppFlow flow"
  type        = string
}

variable "source_connector_type" {
  description = "Type of the source connector"
  type        = string
}

variable "destination_connector_type" {
  description = "Type of the destination connector"
  type        = string
}

variable "source_fields" {
  description = "List of source fields for the flow task"
  type        = list(string)
}

variable "destination_field" {
  description = "Destination field for the flow task"
  type        = string
}

variable "trigger_type" {
  description = "Type of trigger for the flow"
  type        = string
}

variable "cloudwatch_log_stream_arn" {
  description = "ARN of the CloudWatch log stream for flow logging"
  type        = string
}

variable "fail_on_first_destination_error" {
  description = "Whether to fail on first destination error"
  type        = bool
  default     = true
}

variable "error_handling_bucket_prefix" {
  description = "Prefix for the S3 bucket used for error handling"
  type        = string
  default     = "appflow-errors/"
}

variable "error_handling_bucket_name" {
  description = "Name of the S3 bucket used for error handling"
  type        = string
}

variable "tags" {
  description = "Tags to apply to AppFlow resources"
  type        = map(string)
  default     = {}
}