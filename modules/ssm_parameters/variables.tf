variable "parameters" {
  description = "Map of SSM parameters to create"
  type = map(object({
    value  = string
    type   = string
  }))
}

