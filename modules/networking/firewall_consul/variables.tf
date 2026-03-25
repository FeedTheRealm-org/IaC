variable "name" { type = string }

variable "allowed_security_group_ids" {
  type    = list(string)
  default = []
}
