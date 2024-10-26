variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "key_algorithm" {
  description = "Specifies the algorithm of the public and private key pair that the certificate uses"
  type        = string
  default     = "RSA_2048"
  validation {
    condition     = contains(["RSA_2048", "RSA_4096", "EC_prime256v1", "EC_secp384r1"], var.key_algorithm)
    error_message = "Invalid key algorithm. Must be one of RSA_2048, RSA_4096, EC_prime256v1, or EC_secp384r1."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_private_ca" {
  description = "Whether to create a private Certificate Authority"
  type        = bool
  default     = false
}

variable "private_ca_common_name" {
  description = "Common name for the private CA"
  type        = string
  default     = "example.com"
}