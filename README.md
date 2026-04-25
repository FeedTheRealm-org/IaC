# IaC repository for Feed The Realm

This repository declares as code the state of the current AWS infrastructure of the project.

- [How to use](./docs/how-to-use.md)
- [Current infrastructure and bootstrap behavior](./docs/infrastructure-current-state.md)
- [External/manual commands](./docs/external-commands.md)

## Structure

The repo is divided in two main folders, one contains reusable terraform modules (basic definitions of resources) and the other contains
the available environments for the project.

Each module folder has its own `main.tf` and if necessary its own `variables.tf` (input) and `outputs.tf`.

The environments also have this, but their `main.tf` is the entrypoint for all resource creation, its outputs will be printed to the screen after applying
the state changes. Additionally there is a `backend.tf` file which declares where the states will be saved after each application.

```bash
.
├── docs/                     # Documentation files
├── envs/
│   └── prod/                 # Production environment setup
│       ├── backend.tf
│       ├── main.tf           # Main definition of created resources
│       └── outputs.tf
├── modules/                  # Reusable components
│   ├── bucket/
│   ├── compute/
│   ├── container_registry/
│   ├── identity/             # IAM, Roles, OIDC mappings
│   ├── networking/           # DNS, Security Groups, Firewalls
│   └── parameter_store/      # SSM / Configuration parameters
├── scripts/                  # Setup / Configuration bash scripts
└── README.md
```

## Backend

The current status of the backend is an **S3** bucket that saves the terraform states in `prod/terraform.tfstate` in an encrypted manner.

⚠️ Warning: there is no DynamoDB state lock configured. Coordinate with the team before running apply operations.

## Current Infrastructure

For the current deployed state and bootstrap behavior, use:

- [Current infrastructure and bootstrap behavior](./docs/infrastructure-current-state.md)

In short, prod currently includes:

- Identity: GitHub OIDC + CI roles + EC2 runtime role
- Compute: one core node and a variable number of Nomad clients
- Networking: security groups, Elastic IPs, Route53 public/private DNS
- Platform services: Nomad + Consul + Datadog, plus optional NGINX HTTPS on core
- Data/services: ECR repos, S3/CloudFront assets, SSM parameter namespaces

## External resources and prerequisites

- Terraform backend S3 bucket (created outside Terraform)
- Existing VPC passed through `vpc_id`
- Registrar NS delegation for the public domain hosted zone

See [external commands](./docs/external-commands.md) for command history/examples.

## References

- [Terraform AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform docs](https://developer.hashicorp.com/terraform/docs)
- [AWS CLI docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
- [GitHub Actions with AWS](https://github.com/orgs/aws-actions/repositories?type=all)
- [GitHub OIDC docs](https://docs.github.com/en/actions/reference/security/oidc#methods-for-requesting-the-oidc-token)
