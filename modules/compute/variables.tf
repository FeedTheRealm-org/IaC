variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy the EC2 instance"
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
}

variable "ssh_key_name" {
  description = "SSH key-pair name"
  type        = string
}

variable "environment" {
  description = "Instance runtinme environment"
  type        = string
}

variable "nomad_version" {
  description = "Nomad version used in bootstrap"
  type        = string
}

variable "nomad_role" {
  description = "Node role in the Nomad cluster (server or client)"
  type        = string
}

variable "nomad_bootstrap_expect" {
  description = "Number of servers to expect in the cluster for bootstrapping (server role only)"
  type        = number
  default     = 1
}

variable "nomad_server_private_ips" {
  description = "Nomad server private IPs used by clients"
  type        = list(string)
  default     = []
}
