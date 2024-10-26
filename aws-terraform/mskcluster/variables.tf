variable "cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version for the MSK cluster"
  type        = string
  default     = "2.8.1"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes in the cluster"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Instance type for the MSK broker nodes"
  type        = string
  default     = "kafka.m5.large"
}

variable "client_subnets" {
  description = "List of subnet IDs for the MSK cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the MSK cluster"
  type        = list(string)
}

variable "ebs_volume_size" {
  description = "Size of EBS volume for each broker node (in GB)"
  type        = number
  default     = 1000
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption at rest"
  type        = string
}

variable "cloudwatch_log_group" {
  description = "Name of the CloudWatch log group for MSK logs"
  type        = string
}

variable "s3_logs_bucket" {
  description = "Name of the S3 bucket for MSK logs"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for TLS authentication"
  type        = string
}

variable "scram_secret_arns" {
  description = "List of ARNs for SCRAM secrets"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the MSK cluster"
  type        = map(string)
  default     = {}
}