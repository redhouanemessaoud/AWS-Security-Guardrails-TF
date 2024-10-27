variable "training_job_name" {
  description = "Name of the SageMaker training job"
  type        = string
}

variable "endpoint_config_name" {
  description = "Name of the SageMaker endpoint configuration"
  type        = string
}

variable "model_name" {
  description = "Name of the SageMaker model"
  type        = string
}

variable "initial_instance_count" {
  description = "Initial number of instances for the endpoint"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for SageMaker resources"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for SageMaker execution"
  type        = string
}

variable "container_image" {
  description = "Docker image for the SageMaker model"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for VPC configuration"
  type        = list(string)
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "s3_output_path" {
  description = "S3 path for output data"
  type        = string
}

variable "training_image" {
  description = "Docker image for training"
  type        = string
}

variable "instance_count" {
  description = "Number of instances for training or monitoring jobs"
  type        = number
  default     = 1
}

variable "volume_size_in_gb" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 30
}

variable "notebook_instance_name" {
  description = "Name of the SageMaker notebook instance"
  type        = string
}

variable "notebook_instance_type" {
  description = "Instance type for the notebook instance"
  type        = string
}

variable "notebook_role_arn" {
  description = "ARN of the IAM role for the notebook instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the notebook instance"
  type        = string
}

variable "data_quality_job_name" {
  description = "Name of the data quality job definition"
  type        = string
}

variable "data_quality_image_uri" {
  description = "URI of the data quality monitoring image"
  type        = string
}

variable "endpoint_name" {
  description = "Name of the SageMaker endpoint"
  type        = string
}

variable "domain_name" {
  description = "Name of the SageMaker domain"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "data_capture_s3_uri" {
  description = "S3 URI for data capture output"
  type        = string
}

variable "flow_definition_name" {
  description = "Name of the SageMaker flow definition"
  type        = string
}

variable "human_task_ui_arn" {
  description = "ARN of the human task UI"
  type        = string
}

variable "task_title" {
  description = "Title of the human review task"
  type        = string
}

variable "task_description" {
  description = "Description of the human review task"
  type        = string
}

variable "task_count" {
  description = "Number of human workers to assign to a task"
  type        = number
  default     = 1
}

variable "task_availability_lifetime_in_seconds" {
  description = "Time that a task remains available for review by human workers"
  type        = number
  default     = 3600 # 1 hour
}

variable "work_team_arn" {
  description = "ARN of the work team"
  type        = string
}