# Current infrastructure and bootstrap behavior

This document is the single source of truth for the current production Terraform footprint.
It is intentionally concise and operational.

## Production snapshot

The production environment in envs/prod provisions:

- Identity:
  - GitHub OIDC provider
  - GitHub Actions roles for core-service and game
  - EC2 instance role/profile (SSM read/write scope, ECR pull, S3 upload)
- Compute:
  - 1 core EC2 node (Consul server + Nomad server)
  - N Nomad client EC2 nodes (Consul client + Nomad client)
  - Datadog agent container on all nodes
  - Optional NGINX + Certbot on core (enabled in prod)
- Networking:
  - Security groups for HTTP/HTTPS, SSH, UDP game traffic, Nomad, and Consul
  - One EIP for core and one EIP per client
- Service/data resources:
  - Route53 public and private hosted zones
  - ECR repositories (core-service immutable, ftr-server mutable)
  - S3 buckets + CloudFront distributions (map-driven)
  - SSM parameter namespaces for application/runtime configuration

## DNS model

A single module handles both zone types:

- Public hosted zone:
  - `zone_name = public_domain_name`
  - no `vpc_id`
  - records include apex (`@`), `www`, `core`, and dynamic client records (`s1..sn`)
- Private hosted zone:
  - `zone_name = internal`
  - `vpc_id` associated
  - records: `nomad.internal`, `core-service.internal`, `consul.internal`

## Bootstrap behavior (EC2 user_data)

All nodes:

- Install Docker, Consul, Nomad, CNI plugins, and AWS tooling.
- Configure ECR credential helper.
- Start Consul and Nomad with TLS.
- Start Datadog agent container.

Server-only behavior:

- Bootstrap Nomad ACLs.
- Write runtime tokens to SSM:
  - `/nomad/root_token`
  - `/nomad/NOMAD_TOKEN`

Core-only optional behavior (enabled in prod):

- Render and run NGINX + Certbot setup for `core.<public_domain_name>`.
- Proxy to `core-service.internal:34782`.

## HTTPS requirements

- `core.<public_domain_name>` resolves to core EIP.
- HTTP/HTTPS ingress enabled (80/443).
- Instance has outbound internet access for package and certificate operations.

## SSM parameters summary

Terraform-managed:

- `/core-service/*`
- `/ftr-server/*`
- `/monitoring/dd_api_key`
- `/nomad/NOMAD_ADDR`
- `/consul/*`

Required pre-populated before bootstrap (scripted):

- `/nomad/tls/*`

Runtime-generated during bootstrap:

- `/nomad/root_token`
- `/nomad/NOMAD_TOKEN`

## External prerequisites (not Terraform-managed)

- Terraform backend S3 bucket.
- Existing VPC passed as `vpc_id`.
- Registrar NS delegation for the public hosted zone.
- Sensitive `TF_VAR_*` values loaded from `envs/prod/.env`.

