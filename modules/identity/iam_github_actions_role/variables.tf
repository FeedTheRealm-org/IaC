variable "name" {
  type        = string
  description = "IAM role name"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub OIDC provider"
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the ECR repository this role can push to"
}

variable "github_org" {
  type        = string
}

variable "github_repo" {
  type        = string
}

variable "github_branch" {
  type        = string
}

