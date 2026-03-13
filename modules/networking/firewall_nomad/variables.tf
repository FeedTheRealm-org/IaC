variable "name" {
  description = "Nomad security group name"
  type        = string
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to reach Nomad API port 4646"
  type        = list(string)
  default     = []
}
