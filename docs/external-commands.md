# External Commands

This document contains all the external commands that where ran utilizing the AWS cli or other.

⚠️ Keep this up-to-date always **(these cannot be destroyed or modified by terraform)**!

## Terraform state s3 bucket

```bash
# Create bucket
aws s3api create-bucket --bucket feedtherealm-terraform-state --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2 --profile iamadmin

# Server encryption
aws s3api put-bucket-encryption --bucket feedtherealm-terraform-state --server-side-encryption-configuration '{\
    "Rules": [{\
    "ApplyServerSideEncryptionByDefault": {\
        "SSEAlgorithm": "AES256"\
      }\
    }]\
  }' --profile iamadmin

# Secure bucket
aws s3api put-public-access-block \
  --bucket feedtherealm-terraform-state \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile iamadmin
```

## Nomad TLS bootstrap material in SSM

The EC2 bootstrap depends on `/nomad/tls/*` parameters. They are generated and uploaded by script.

```bash
AWS_PROFILE=<name> ./scripts/nomad_tls_setup.sh envs/prod/nomad_tls us-east-2
```

This script writes:

- `/nomad/tls/ca_cert`
- `/nomad/tls/server_cert`
- `/nomad/tls/server_key`
- `/nomad/tls/client_cert`
- `/nomad/tls/client_key`
- `/nomad/tls/cli_cert`
- `/nomad/tls/cli_key`

## Consul gossip secret

This key is generated via:

```bash
consul keygen
```

## Manual DNS delegation

The public hosted zone is created by Terraform, but parent-domain/registrar name server delegation is external (PORKBUN).
After initial apply, copy `public_dns_name_servers` output values and update registrar NS records for the domain.

```bash
# Example NS records to add in registrar (current ones):
ns-771.awsdns-32.net.
ns-1903.awsdns-45.co.uk.
ns-1276.awsdns-31.org.
ns-409.awsdns-51.com.
```
