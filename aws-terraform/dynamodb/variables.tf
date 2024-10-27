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

variable "attributes" {
  description = "List of nested attribute definitions"
  type = list(object({
    name = string
    type = string
  }))
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

variable "kms_key_arn" {
  description = "The ARN of the CMK that should be used for the AWS KMS encryption"
  type        = string
}

variable "ttl_attribute" {
  description = "The name of the TTL attribute"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "read_capacity" {
  description = "The number of read units for this table"
  type = object({
    min          = number
    max          = number
    target_value = number
  })
  default = {
    min          = 5
    max          = 20
    target_value = 70
  }
}

variable "write_capacity" {
  description = "The number of write units for this table"
  type = object({
    min          = number
    max          = number
    target_value = number
  })
  default = {
    min          = 5
    max          = 20
    target_value = 70
  }
}

variable "dax_cluster_name" {
  description = "Name of the DAX cluster"
  type        = string
  default     = null
}

variable "dax_iam_role_arn" {
  description = "IAM role ARN for DAX cluster"
  type        = string
  default     = null
}

variable "dax_node_type" {
  description = "Node type for DAX cluster"
  type        = string
  default     = "dax.r4.large"
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

variable "global_table_regions" {
  description = "List of region names for creating a global table"
  type        = list(string)
  default     = []
}

variable "global_table_kms_key_arns" {
  description = "Map of region names to KMS key ARNs for global table encryption"
  type        = map(string)
  default     = {}
}