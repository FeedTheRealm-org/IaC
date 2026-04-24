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

output "core_nomad_server_id" {
  value = module.core_nomad_server.id
}

output "core_nomad_server_private_ip" {
  value = module.core_nomad_server.private_ip
}

output "core_nomad_server_elastic_ip" {
  value = module.core_nomad_server_eip.public_ip
}

output "nomad_client_ids" {
  value = { for k, m in module.nomad_clients : k => m.id }
}

output "nomad_client_private_ips" {
  value = { for k, m in module.nomad_clients : k => m.private_ip }
}

output "nomad_client_elastic_ips" {
  value = { for k, m in module.nomad_client_eips : k => m.public_ip }
}

output "nomad_internal_api" {
  value = "http://${module.core_nomad_server.private_ip}:4646"
}

output "public_dns_zone_id" {
  value = module.public_dns_records.zone_id
}

output "public_dns_name_servers" {
  value = module.public_dns_records.name_servers
}

output "public_dns_record_fqdns" {
  value = module.public_dns_records.record_fqdns
}
