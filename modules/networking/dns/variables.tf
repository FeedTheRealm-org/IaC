variable "zone_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "records" {
  type        = map(string)
  description = "Map of record name to IP address e.g. { nomad = '172.31.x.x' }"
  default     = {}
}
