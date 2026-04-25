output "zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}

output "record_fqdns" {
  value = {
    for k, r in aws_route53_record.this : k => r.fqdn
  }
}
