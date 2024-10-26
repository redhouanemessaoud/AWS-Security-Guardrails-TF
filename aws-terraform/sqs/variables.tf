variable "queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "kms_key_id" {
  description = "The ID of the KMS key to use for encryption"
  type        = string
}

variable "visibility_timeout" {
  description = "The visibility timeout for the queue in seconds"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message"
  type        = number
  default     = 345600 # 4 days
}

variable "max_message_size" {
  description = "The maximum size of a message in bytes"
  type        = number
  default     = 262144 # 256 KiB
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive"
  type        = number
  default     = 0
}

variable "is_fifo_queue" {
  description = "Whether the queue is a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "max_receive_count" {
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue"
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the dead-letter queue"
  type        = number
  default     = 1209600 # 14 days
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "allowed_aws_accounts" {
  description = "List of AWS account IDs allowed to access the SQS queue"
  type        = list(string)
}

variable "queue_depth_threshold" {
  description = "The threshold for queue depth alarm"
  type        = number
  default     = 100
}

variable "oldest_message_threshold" {
  description = "The threshold for oldest message age alarm in seconds"
  type        = number
  default     = 3600 # 1 hour
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for CloudWatch alarms"
  type        = string
}