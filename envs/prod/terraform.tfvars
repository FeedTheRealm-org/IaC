# Module Instantiation
buckets = {
  cosmetics = {
    name = "feedtherealm-prod-cosmetics"
    tags = { purpose = "cosmetics" }
  }
  worlds = {
    name = "feedtherealm-prod-worlds"
    tags = { purpose = "worlds" }
  }
}

# Non-secret parameters
environment             = "production"
db_should_migrate       = "true"
email_sender_address    = "atusgames.official@gmail.com"
session_token_duration  = "24h"
email_logo_url          = "https://avatars.githubusercontent.com/u/231922724?s=400"
public_domain_name      = "feedtherealm.world"
public_apex_ipv4        = "216.198.79.1"
public_www_cname_target = "7199996a935df1e3.vercel-dns-017.com."
public_dns_ttl          = 300
nomad_cert_path         = "/etc/nomad.d/tls/ca.pem"
ami                     = "ami-0b0b78dcacbab728f" # Amazon Linux 2023 with kernel 6.1, 2024-06-01.
vpc_id                  = "vpc-040aac61ba7d0c39b"

# Nomad cluster topology defaults
aws_region                      = "us-east-2"
core_nomad_server_instance_type = "t3.micro"
nomad_client_nodes = {
  nomad-client-a = {
    name                    = "nomad-client-a"
    instance_type           = "t3.small"
    enable_udp_game_traffic = true
  }
}
nomad_version  = "1.11.3"
consul_version = "1.20.1"
