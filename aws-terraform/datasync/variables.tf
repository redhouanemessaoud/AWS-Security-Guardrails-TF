variable "source_location_arn" {
  description = "ARN of the source location for the DataSync task"
  type        = string
}

variable "destination_location_arn" {
  description = "ARN of the destination location for the DataSync task"
  type        = string
}

variable "task_name" {
  description = "Name of the DataSync task"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for DataSync task logging"
  type        = string
}

variable "bytes_per_second" {
  description = "Limits the bandwidth utilized in the data transfer"
  type        = number
  default     = -1  # No limit by default
}

variable "include_pattern" {
  description = "Pattern to include specific files/folders in the data transfer"
  type        = string
  default     = "**"  # Include everything by default
}

variable "source_vpc_endpoint_arns" {
  description = "List of VPC endpoint ARNs for the source location"
  type        = list(string)
  default     = []
}

variable "destination_vpc_endpoint_arns" {
  description = "List of VPC endpoint ARNs for the destination location"
  type        = list(string)
  default     = []
}