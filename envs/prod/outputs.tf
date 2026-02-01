output "core_service_ecr_url" {
  value = module.core_service_ecr.repository_url
}

output "core_service_ci_role_arn" {
  value = module.core_service_ci_role.role_arn
}

