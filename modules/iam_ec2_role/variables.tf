variable "name" {
  type        = string
  description = "EC2 role name"
}

variable "ssm_parameter_path" {
  description = "SSM parameter path this EC2 can read (e.g. /core-service/*)"
  type        = string
}

