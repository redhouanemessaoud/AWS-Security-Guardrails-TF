variable "stream_name" {
  description = "The name of the Kinesis stream"
  type        = string
}

variable "shard_count" {
  description = "The number of shards for the Kinesis stream"
  type        = number
  default     = 1
}

variable "retention_period" {
  description = "The number of hours to retain data records in the stream"
  type        = number
  default     = 24
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to use for encryption"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_enhanced_fanout" {
  description = "Enable enhanced fan-out for Kinesis Data Streams consumers"
  type        = bool
  default     = false
}

variable "create_firehose_delivery_stream" {
  description = "Whether to create a Kinesis Firehose delivery stream"
  type        = bool
  default     = false
}

variable "firehose_role_arn" {
  description = "The ARN of the IAM role for Kinesis Firehose"
  type        = string
  default     = ""
}

variable "firehose_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for Kinesis Firehose delivery"
  type        = string
  default     = ""
}

variable "error_rate_threshold" {
  description = "The threshold for the error rate alarm"
  type        = number
  default     = 0.01
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  type        = string
}