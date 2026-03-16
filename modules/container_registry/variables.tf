variable "name" {
  type        = string
  description = "ECR repository name"
}

variable "is_mutable" {
  type        = bool
  description = "Whether the ECR image can be overwritten"
}

