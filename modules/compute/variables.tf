variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name attached to EC2"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "ssh_key_name" {
  description = "SSH key-pair name"
  type        = string
}

variable "environment" {
  description = "Instance runtinme environment"
  type = string
}
