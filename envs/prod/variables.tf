/* Module Instantiation */
variable "buckets" {
  type = map(object({
    name = string
    tags = map(string)
  }))
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

/* CORE-SERVICE Parameters */

variable "db_should_migrate" {
  type = string
}

variable "email_sender_address" {
  type = string
}

variable "session_token_duration" {
  type = string
}

variable "email_logo_url" {
  type = string
}

variable "brevo_api_key" {
  type      = string
  sensitive = true
}

variable "server_fixed_token" {
  type      = string
  sensitive = true
}

variable "session_token_secret_key" {
  type      = string
  sensitive = true
}

variable "database_ssl_cert_path" {
  type      = string
  sensitive = true
}

variable "database_url" {
  type      = string
  sensitive = true
}

variable "nomad_cert_path" {
  type = string
}

/* FTR-SERVER Parameters */

variable "ftr_core_service_url" {
  type = string
}

/* MONITORING Parameters */

variable "dd_api_key" {
  type      = string
  sensitive = true
}

variable "ssh_key_name" {
  description = "SSH Key name - Only use ssh for debuggin purposes and then deactivate it in main.tf"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ami" {
  description = "EC2 AMI ID. Find the latest Amazon Linux 2023 AMI with: aws ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64 --query Parameter.Value --output text"
  type        = string
}

variable "aws_region" {
  description = "AWS region for bootstrap scripts"
  type        = string
}

variable "core_nomad_server_instance_type" {
  description = "Instance type used by the mixed core-service + Nomad server node"
  type        = string
}

variable "nomad_client_nodes" {
  description = "Nomad client nodes keyed by Nomad node name"
  type = map(object({
    name                    = string
    instance_type           = string
    enable_udp_game_traffic = bool
  }))
}

variable "nomad_version" {
  description = "Nomad version bootstrapped on EC2 nodes"
  type        = string
}

variable "consul_version" {
  description = "Consul version to install"
  type        = string
}

variable "consul_encrypt_key" {
  description = "Consul gossip encryption key (generate with: consul keygen)"
  type        = string
  sensitive   = true
}
