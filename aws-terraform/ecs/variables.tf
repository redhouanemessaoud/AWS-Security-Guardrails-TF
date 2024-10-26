variable "task_definition_family" {
  description = "Family name for the task definition"
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the task in MiB"
  type        = number
  default     = 512
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for container logs"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "efs_volume_name" {
  description = "Name of the EFS volume"
  type        = string
  default     = ""
}

variable "efs_container_path" {
  description = "Container path for EFS mount"
  type        = string
  default     = ""
}

variable "efs_file_system_id" {
  description = "ID of the EFS file system"
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_exec_log_group_name" {
  description = "Name of the CloudWatch log group for ECS Exec logs"
  type        = string
}

variable "ecs_exec_s3_bucket_name" {
  description = "Name of the S3 bucket for ECS Exec logs"
  type        = string
}

variable "ecs_exec_s3_key_prefix" {
  description = "S3 key prefix for ECS Exec logs"
  type        = string
  default     = "ecs-exec-logs"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting ECS Exec logs"
  type        = string
}