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

The current resources created by terraform are (4):
- aws_ecr_repository (core service)
- aws_iam_openid_connect_provider (github)
- aws_iam_role (AssumeRoleWithWebIdentity for feedtherealm-org/core-service)
- aws_iam_role_policy (ecr push)

Externally created resources (1):
- S3 bucket (feedtherealm-terraform-state)
