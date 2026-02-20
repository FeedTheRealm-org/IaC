variable "name" {
  type        = string
  description = "EC2 role name"
}

variable "ssm_parameter_path" {
  description = "SSM parameter path this EC2 can read (e.g. /core-service/*)"
  type        = string
}

variable "upload_buckets" {
  description = "List of S3 bucket ARNs the EC2 may upload to"
  type        = list(string)
}
