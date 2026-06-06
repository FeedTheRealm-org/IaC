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
environment       = "production"
db_should_migrate = "true"

email_receiver_address = "atusgames.official@gmail.com"
email_sender_address   = "noreply@feedtherealm.world"
brevo_dkim_1           = "b1.feedtherealm-world.dkim.brevo.com"
brevo_dkim_2           = "b2.feedtherealm-world.dkim.brevo.com"
brevo_dmarc_value      = "v=DMARC1; p=none; rua=mailto:rua@dmarc.brevo.com"
cors_allowed_origins   = "https://www.feedtherealm.world,https://admin.feedtherealm.world"

email_logo_url            = "https://avatars.githubusercontent.com/u/231922724?s=400"
stripe_real_prices        = "false"
public_domain_name        = "feedtherealm.world"
public_apex_ipv4          = "216.198.79.1"
public_www_cname_target   = "7199996a935df1e3.vercel-dns-017.com."
public_admin_cname_target = "b6a01535321a2d1b.vercel-dns-017.com."
public_dns_ttl            = 300
nomad_cert_path           = "/etc/nomad.d/tls/ca.pem"
ami                       = "ami-0b0b78dcacbab728f" # Amazon Linux 2023 with kernel 6.1, 2024-06-01.
vpc_id                    = "vpc-040aac61ba7d0c39b"

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
