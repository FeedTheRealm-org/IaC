variable "name" {
  type        = string
  description = "EC2 role name"
}

variable "ssm_parameter_paths" {
  type = list(string)
}

variable "ssm_write_parameter_paths" {
  type = list(string)
}

variable "upload_buckets" {
  description = "List of S3 bucket ARNs the EC2 may upload to"
  type        = list(string)
}
