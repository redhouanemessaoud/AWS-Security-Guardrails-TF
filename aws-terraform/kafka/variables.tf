variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "kafka_version" {
  description = "The version of Kafka to use"
  type        = string
  default     = "2.8.1"  # Use the latest stable version
}

variable "number_of_broker_nodes" {
  description = "The number of broker nodes in the cluster"
  type        = number
  default     = 3  # Recommended for multi-AZ deployment
}

variable "instance_type" {
  description = "The instance type to use for the Kafka brokers"
  type        = string
  default     = "kafka.m5.large"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for MSK deployment"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for MSK cluster"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption at rest"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for MSK logs"
  type        = string
}

variable "s3_logs_bucket" {
  description = "Name of the S3 bucket for MSK logs"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for mutual TLS authentication"
  type        = string
}

variable "scram_secret_arn" {
  description = "ARN of the Secrets Manager secret for SASL/SCRAM authentication"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

variable "allowed_principal_arns" {
  description = "List of ARNs allowed to perform specific topic operations"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}