variable "server_environment" {
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

