variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "The number of read units for this table. If the billing_mode is PROVISIONED, this field is required"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for this table. If the billing_mode is PROVISIONED, this field is required"
  type        = number
  default     = null
}

variable "kms_key_arn" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption"
  type        = string
}

variable "enable_streams" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the stream for this table"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "enable_ttl" {
  description = "Indicates whether ttl is enabled"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "The name of the table attribute to store the TTL timestamp in"
  type        = string
  default     = "TTL"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = "Describe a GSI for the table"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = []
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for DynamoDB table"
  type        = bool
  default     = false
}

variable "read_min_capacity" {
  description = "Minimum read capacity for autoscaling"
  type        = number
  default     = 5
}

variable "read_max_capacity" {
  description = "Maximum read capacity for autoscaling"
  type        = number
  default     = 20
}

variable "write_min_capacity" {
  description = "Minimum write capacity for autoscaling"
  type        = number
  default     = 5
}

variable "write_max_capacity" {
  description = "Maximum write capacity for autoscaling"
  type        = number
  default     = 20
}

variable "read_target_utilization" {
  description = "Target utilization (%) for read autoscaling"
  type        = number
  default     = 70
}

variable "write_target_utilization" {
  description = "Target utilization (%) for write autoscaling"
  type        = number
  default     = 70
}

variable "create_dax_cluster" {
  description = "Whether to create a DAX cluster"
  type        = bool
  default     = false
}

variable "dax_cluster_name" {
  description = "Name of the DAX cluster"
  type        = string
  default     = ""
}

variable "dax_iam_role_arn" {
  description = "IAM role ARN for DAX cluster"
  type        = string
  default     = ""
}

variable "dax_node_type" {
  description = "Node type for DAX cluster"
  type        = string
  default     = "dax.t3.small"
}

variable "dax_replication_factor" {
  description = "Replication factor for DAX cluster"
  type        = number
  default     = 3
}

variable "dax_availability_zones" {
  description = "List of Availability Zones for DAX cluster"
  type        = list(string)
  default     = []
}

variable "create_global_table" {
  description = "Whether to create a global table"
  type        = bool
  default     = false
}

variable "global_table_regions" {
  description = "List of regions for global table"
  type        = list(string)
  default     = []
}

variable "global_table_kms_key_arns" {
  description = "Map of region to KMS key ARN for global table replicas"
  type        = map(string)
  default     = {}
}