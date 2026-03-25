# How to use

This document contains useful commands to manage the infrastructure this repository defines.

## Get started

Configure yout aws account (you need access keys):

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
AWS_PROFILE=<name> terraform plan
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

## Environments & Environment variables

When you need to plan or apply you will need your .env in place, for that checkout the `.env.example`.
It containts a series of exports that are needed and will be used by terraform (they are secrets, you know where to get them from).

```bash
source .env # loads the environment variables into current shell
# ready for terraform stuff ...
```

**About environments**, you need to `cd` into the specific environment you want to make changes to, for example:

```bash
cd envs/prod # now everything you do will affect the production environment!
```

## Additional Scripts and Operations

### Nomad Initialization

The `scripts/nomad_tls_setup.sh` script is provided to generate and deploy TLS certificates required for secure internal communication across the Nomad servers and clients. Run this script as needed prior to applying your Node constraints if you're rotating keys, or during initial server bootstrap.

## AWS CLI commands

Some other useful aws commands to run locally are:

```bash
# Get the latests SSM commands that runned
aws ssm list-commands --max-results 5 --profile <name>

# Get a table showing EC2 instances metadata
aws ssm describe-instance-information --region <region> --query "InstanceInformationList[*].[InstanceId, PingStatus, PlatformType, Tags]" --output table --profile <name>

# Get specific command to check output and debug
aws ssm list-command-invocations \
    --command-id <id> \
    --details --profile <name>
```
