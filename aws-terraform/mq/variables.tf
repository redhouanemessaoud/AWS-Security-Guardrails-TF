variable "broker_name" {
  description = "Name of the MQ broker"
  type        = string
}

variable "engine_type" {
  description = "Type of broker engine"
  type        = string
  default     = "ActiveMQ"
}

variable "engine_version" {
  description = "Version of the broker engine"
  type        = string
}

variable "instance_type" {
  description = "Instance type of the broker"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "kms_key_id" {
  description = "ID of the KMS key for encryption"
  type        = string
}

variable "maintenance_day_of_week" {
  description = "Day of week for maintenance window"
  type        = string
  default     = "SUNDAY"
}

variable "maintenance_time_of_day" {
  description = "Time of day for maintenance window"
  type        = string
  default     = "03:00"
}

variable "maintenance_time_zone" {
  description = "Time zone for maintenance window"
  type        = string
  default     = "UTC"
}

variable "admin_username" {
  description = "Username for the admin user"
  type        = string
}

variable "admin_password" {
  description = "Password for the admin user"
  type        = string
  sensitive   = true
}

variable "keystore_path" {
  description = "Path to the keystore file"
  type        = string
}

variable "keystore_password" {
  description = "Password for the keystore"
  type        = string
  sensitive   = true
}

variable "truststore_path" {
  description = "Path to the truststore file"
  type        = string
}

variable "truststore_password" {
  description = "Password for the truststore"
  type        = string
  sensitive   = true
}

variable "cpu_utilization_threshold" {
  description = "Threshold for CPU utilization alarm"
  type        = number
  default     = 80
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}