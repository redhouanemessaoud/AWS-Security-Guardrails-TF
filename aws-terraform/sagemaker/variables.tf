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
  description = "Instance type for the endpoint"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the IAM role for SageMaker execution"
  type        = string
}

variable "container_image" {
  description = "Container image for the SageMaker model"
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
  description = "ID of the KMS key for encryption"
  type        = string
}

variable "training_instance_type" {
  description = "Instance type for training jobs"
  type        = string
}

variable "training_instance_count" {
  description = "Number of instances for training jobs"
  type        = number
  default     = 1
}

variable "volume_size_in_gb" {
  description = "Size of the EBS volume in GB for training jobs"
  type        = number
  default     = 30
}

variable "notebook_name" {
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
  description = "ID of the subnet for the notebook instance"
  type        = string
}

variable "data_quality_job_name" {
  description = "Name of the SageMaker data quality job"
  type        = string
}

variable "data_quality_role_arn" {
  description = "ARN of the IAM role for the data quality job"
  type        = string
}

variable "data_quality_image_uri" {
  description = "URI of the image for the data quality job"
  type        = string
}

variable "data_quality_instance_count" {
  description = "Number of instances for the data quality job"
  type        = number
  default     = 1
}

variable "data_quality_instance_type" {
  description = "Instance type for the data quality job"
  type        = string
}

variable "domain_name" {
  description = "Name of the SageMaker domain"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC for the SageMaker domain"
  type        = string
}

variable "endpoint_name" {
  description = "Name of the SageMaker endpoint"
  type        = string
}

variable "alarm_names" {
  description = "List of CloudWatch alarm names for endpoint auto-rollback"
  type        = list(string)
  default     = []
}

variable "flow_definition_name" {
  description = "Name of the SageMaker flow definition"
  type        = string
}

variable "flow_definition_role_arn" {
  description = "ARN of the IAM role for the flow definition"
  type        = string
}

variable "human_task_ui_arn" {
  description = "ARN of the human task UI for the flow definition"
  type        = string
}

variable "task_count" {
  description = "Number of tasks for the flow definition"
  type        = number
  default     = 1
}

variable "task_description" {
  description = "Description of the task for the flow definition"
  type        = string
}

variable "task_title" {
  description = "Title of the task for the flow definition"
  type        = string
}

variable "workflow_arn" {
  description = "ARN of the workflow for the flow definition"
  type        = string
}

variable "s3_output_path" {
  description = "S3 output path for the flow definition"
  type        = string
}