variable "zone_name" {
  description = "Public Route53 hosted zone name"
  type        = string
}

variable "allow_overwrite" {
  description = "Allow Terraform to overwrite existing records with the same name and type"
  type        = bool
  default     = true
}

variable "records" {
  description = "Map of DNS label to record config. Use @ for apex zone record."
  type = map(object({
    type    = string
    ttl     = number
    records = list(string)
  }))
}
