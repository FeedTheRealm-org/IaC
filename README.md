# IaC repository for Feed The Realm

This repository declares as code the state of the current AWS infrastructure of the project.

[[How to use >]](./docs/how-to-use.md)

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

⚠️ The backend does not have a DynamoDB lock, therefore concurrent applies can cause the infrastructure to corrupt and will have to be fixed manually,
so **please let the whole team know before applying a infrastructural change!**

## Resources

⚠️ **Keep this up to date after any change!**

The current resources created by terraform are the following:

### IAM roles + policies

#### > GitHub Actions CI/CD roles

- `core_service_ci_role`: Role for GitHub Actions (core-service repo)
- `ftr_server_ci_role`: Role for GitHub Actions (game repo)

#### > EC2 roles

- `generic-ec2-role`: Instance profile for EC2 nodes with SSM, S3 upload, and ECR pull access.

---

### OIDC providers

- `github_oidc`: GitHub OpenID Connect provider

---

### SSM Parameters

- `/core-service/*`: 15 parameters (including S3 bucket configs)
- `/ftr-server/*`: 1 parameter
- `/monitoring/*`: Datadog agent configuration
- `/nomad/*`: Nomad bootstrap/address parameters
- `/consul/*`: Consul address and encryption parameters

---

### Security groups

- `http_sg`: HTTP access (TCP 80)
- `ssh_sg`: SSH access (TCP 22) - generally for debugging
- `ftr_server_sg`: FTR game server UDP traffic access
- `nomad_sg`: Internal Nomad cluster communication
- `consul_sg`: Internal Consul cluster communication

---

### ECR

- `core-service` (Immutable)
- `ftr-server` (Mutable)

---

### EC2 (Compute)

- `core_nomad_server`: Main Nomad and Consul Server instance
- `nomad_clients`: Variable number of Nomad and Consul client nodes

---

### S3 + CloudFront Buckets

- Variable-driven bucket configurations (e.g. `cosmetics`, `worlds`)

---

### DNS

- `internal`: Internal Route53 Zone for service discovery (`nomad.internal`, `core-service.internal`, `consul.internal`)

## External Resources

The externally created resources are (1) the following:

- S3 bucket (feedtherealm-terraform-state)

[[More Info >]](./docs/external-commands.md) (cli commands history)

## References

Some useful links..

- [Terraform for AWS docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [General terraform docs](https://developer.hashicorp.com/terraform/docs)
- [AWS cli docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
- [AWS github actions](https://github.com/orgs/aws-actions/repositories?type=all) + [OIDC](https://docs.github.com/en/actions/reference/security/oidc#methods-for-requesting-the-oidc-token) + [GH Thumbprint](https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/)
- [AWS general docs](https://docs.aws.amazon.com/)
