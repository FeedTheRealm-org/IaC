output "core_service_ecr_url" {
  value = module.core_service_ecr.repository_url
}

output "core_service_ci_role_arn" {
  value = module.core_service_ci_role.role_arn
}

output "s3_buckets_cloudfront_domains" {
  description = "CloudFront domain names per bucket"
  value = {
    for k, m in module.s3_buckets : k => m.cloudfront_domain_name
  }
}

output "ec2_id" {
  value = module.ec2.id
}
