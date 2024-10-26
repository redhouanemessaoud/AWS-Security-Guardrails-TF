variable "cluster_identifier" {
  description = "The name of the Redshift cluster"
  type        = string
}

variable "database_name" {
  description = "The name of the first database to be created when the cluster is created"
  type        = string
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "node_type" {
  description = "The node type to be provisioned for the cluster"
  type        = string
}

variable "cluster_type" {
  description = "The cluster type to use"
  type        = string
  default     = "multi-node"
}

variable "number_of_nodes" {
  description = "The number of compute nodes in the cluster"
  type        = number
  default     = 2
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
}

variable "snapshot_retention_period" {
  description = "The number of days to retain automated snapshots"
  type        = number
  default     = 7
}

variable "security_group_id" {
  description = "The ID of the VPC security group to associate with the cluster"
  type        = string
}

variable "subnet_group_name" {
  description = "The name of a cluster subnet group to be associated with this cluster"
  type        = string
}

variable "serverless_namespace_name" {
  description = "The name of the Redshift Serverless namespace"
  type        = string
}

variable "serverless_admin_username" {
  description = "The admin username for Redshift Serverless"
  type        = string
}

variable "serverless_admin_password" {
  description = "The admin password for Redshift Serverless"
  type        = string
  sensitive   = true
}

variable "serverless_db_name" {
  description = "The name of the first database to be created in Redshift Serverless"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for query logging"
  type        = string
}