# IaC repository for Feed The Realm

This repository declares as code the state of the current AWS infrastructure of the project.


## Structure

The repo is divided in two main folders, one contains reusable terraform modules (basic definitions of resources) and the other contains
the available environments for the project.

Each module folder has its own `main.tf` and if necessary its own `variables.tf` (input) and `outputs.tf`.

The environments also have this, but their `main.tf` is the entrypoint for all resource creation, its outputs will be printed to the screen after applying
the state changes. Additionally there is a `backend.tf` file which declares where the states will be saved after each application.

```bash
.
├── envs/
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       └── outputs.tf
├── modules/
│   ├── ecr/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── github_oidc/
│   └── iam_github_actions_role/
```

## Backend

The current status of the backend is an **S3** bucket that saves the terraform states in `prod/terraform.tfstate` in an encrypted manner.

⚠️ The backend does not have a DynamoDB lock, therefore concurrent applies can cause the infrastructure to corrupt and will have to be fixed manually,
so **please let the whole team know before applying a infrastructural change!**

## Resources

⚠️ **Keep this up to date after any change!**

The current resources created by terraform are the following:

### IAM roles + policies (6)

#### > gh ecr pusher roles

- aws_iam_role (AssumeRoleWithWebIdentity for feedtherealm-org/core-service)
- aws_iam_role_policy (ecr push)

#### > ec2 roles

- aws_iam_role (ec2 role)
- aws_iam_role_policy (ssm read)
- 2 x aws_iam_role_policy_attachment (ecr pull and ssm managed)

### OIDC providers (1)
- aws_iam_openid_connect_provider (github)

### SSM Parameters (9)
- core-service environment variables (9 variables)

### Security groups (1)
- aws_security_group (http-only group)

### ECR (1)
- aws_ecr_repository (core service)

### EC2 (1)
- aws_instance

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
