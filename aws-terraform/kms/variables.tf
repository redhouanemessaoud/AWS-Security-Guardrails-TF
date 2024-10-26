variable "key_description" {
  description = "The description of the KMS key"
  type        = string
  default     = "KMS key for secure encryption"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource"
  type        = number
  default     = 30
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region key"
  type        = bool
  default     = false
}

variable "key_policy" {
  description = "A valid policy JSON document for the KMS key"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "key_alias" {
  description = "The alias name for the KMS key"
  type        = string
}

variable "use_imported_key" {
  description = "Whether to use an imported key material"
  type        = bool
  default     = false
}

variable "imported_key_material" {
  description = "The key material to import. This is a base64-encoded string"
  type        = string
  default     = null
}

variable "imported_key_valid_to" {
  description = "The time at which the imported key material expires"
  type        = string
  default     = null
}