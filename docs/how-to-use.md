# How to use

This document describes the operational workflow for the Terraform in this repository.

## Get started

Configure AWS credentials:

```bash
aws configure --profile <name> (e.g. iamadmin)
# Enter account access ID
# Enter account access secret

aws sts get-caller-identity --profile <name>
# Check if your information is printed -> successfully confugured
```

## Terraform commands

<!-- I (human) put those emojis dont delete them they make it easier to read -->

▶️ You need to initialize the terraform files and to connect to the backend (in S3).
This command should be ran once at the start and then once per change to the modules.

```bash
AWS_PROFILE=<name> terraform init [-reconfigure] # reconfigure if unsure if connected to backend
```

📝 Then you can plan the changes for the infrastructure to reflect specified changes in definitions.

```bash
AWS_PROFILE=<name> terraform plan # from /envs/prod
# See the diff of current state and new desired state (none if no changes where made)
```

✅ After revising the infrastructure and if you want to commit to it, apply the changes (do so having in mind it could create/modify/destroy resources).

```bash
AWS_PROFILE=<name> terraform apply
# Shows the plan as before
# At the end prompts for the final decision (type yes to proceed)
```

❌ Done with the infra? might as well blow it up...

```bash
AWS_PROFILE=<name> terraform destroy # DONT DO IT!
```

⟳ One extra command is used to attempt to find any resources held in the state file and update with any drift that has happened in the provider outside of Terraform since it was last ran.

```bash
AWS_PROFILE=<name> terraform refresh
```

## Environment variables

When you need to plan or apply you will need your .env in place, for that checkout the `.env.example`.
It containts a series of exports that are needed and will be used by terraform (they are secrets, you know where to get them from).

```bash
cp envs/prod/.env.example envs/prod/.env # and complete values
source envs/prod/.env
```

Generate/upload Nomad TLS certificates when bootstrapping the cluster for the first time or after rotation:

```bash
AWS_PROFILE=<name> ./scripts/nomad_tls_setup.sh envs/prod/nomad_tls us-east-2 # generation

# Also generate consul gossip key
consul keygen
```

```bash
AWS_PROFILE=<name> terraform -chdir=envs/prod destroy
```

Notes:

- If module sources changed, run `init -reconfigure`.
- There is no DynamoDB state lock, so avoid concurrent applies.

## What happens on EC2 bootstrap

The compute module user data does all of the following:

- Installs Docker, Nomad, Consul, CNI plugins, and AWS tooling.
- Pulls Consul encryption key from SSM and starts Consul.
- Pulls Nomad TLS material from SSM and starts Nomad with TLS + ACL enabled.
- On Nomad server nodes, bootstraps ACLs and writes `/nomad/root_token` and `/nomad/NOMAD_TOKEN` into SSM.
- Optionally runs NGINX + Certbot HTTPS setup when `nginx_enabled=true` (enabled on core node in prod).
- Starts Datadog agent in Docker.

## DNS and HTTPS notes

- Public DNS and private DNS are managed by the same reusable DNS module.
- Public records include `core.<public_domain_name>` and dynamic client records (`s1`, `s2`, ...).
- HTTP security group allows both `80` and `443`.
- NGINX/Certbot on the core node expects DNS for `core.<public_domain_name>` to resolve to the core node EIP.

## 5. Useful operational commands

```bash
# Get the latests SSM commands that runned
aws ssm list-commands --max-results 5 --profile <name>

# Get a table showing EC2 instances metadata
aws ssm describe-instance-information --region <region> --query "InstanceInformationList[*].[InstanceId, PingStatus, PlatformType, Tags]" --output table --profile <name>

# Get specific command to check output and debug
aws ssm list-command-invocations \
    --command-id <id> \
    --details --profile <name>

# Nomad token generated at runtime
aws ssm get-parameter \
    --name /nomad/NOMAD_TOKEN \
    --with-decryption \
    --query Parameter.Value \
    --output text \
    --region us-east-2 \
    --profile <name>

# HTTPS smoke test
curl -I https://core.feedtherealm.world
```
