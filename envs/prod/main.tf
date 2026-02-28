provider "aws" {
  region = "us-east-2"
}

/* --- ECR Creation --- */

module "core_service_ecr" {
  source = "../../modules/container_registry"
  name   = "core-service"
}

/* --- GitHub Access ---  */

module "github_oidc" {
  source = "../../modules/identity/iam_github_oidc/"
}

module "core_service_ci_role" {
  source = "../../modules/identity/iam_github_actions_role"

  name               = "github-actions-core-service"
  oidc_provider_arn  = module.github_oidc.arn
  ecr_repository_arn = module.core_service_ecr.repository_arn

  github_org    = "FeedTheRealm-org"
  github_repo   = "core-service"
  github_branch = "main"
}

/* --- S3 Creation --- */

module "s3_buckets" {
  for_each = var.buckets

  source = "../../modules/bucket"

  bucket_name = each.value.name
  tags        = each.value.tags
}

/* --- EC2 Creation --- */

module "ec2_role" {
  source = "../../modules/identity/iam_ec2_role"

  name               = "generic-ec2-role"
  ssm_parameter_path = "/core-service/*"
  upload_buckets = [
    for m in module.s3_buckets : m.bucket_arn
  ]
}

module "http_sg" {
  source = "../../modules/networking/firewall_http"

  name = "http-only"
}

module "ssh_sg" {
  source = "../../modules/networking/firewall_ssh"

  name = "ssh-firewall"
}

module "ec2" {
  source = "../../modules/compute"

  instance_type         = "t3.micro"
  ssh_key_name          = var.ssh_key_name
  instance_profile_name = module.ec2_role.instance_profile_name
  security_group_ids    = [module.http_sg.id, module.ssh_sg.id] # Only add `module.ssh_sg.id` if activating SSH for debugging!

  tags = {
    Name = "core-runner"
  }
}

/* SSM Parameters */

module "core_service_params" {
  source = "../../modules/parameter_store/ssm_parameters"

  parameters = {
    "/core-service/SERVER_ENVIRONMENT" = {
      value = var.server_environment
      type  = "String"
    }

    "/core-service/DB_SHOULD_MIGRATE" = {
      value = var.db_should_migrate
      type  = "String"
    }

    "/core-service/EMAIL_SENDER_ADDRESS" = {
      value = var.email_sender_address
      type  = "String"
    }

    "/core-service/SESSION_TOKEN_DURATION" = {
      value = var.session_token_duration
      type  = "String"
    }

    "/core-service/EMAIL_LOGO_URL" = {
      value = var.email_logo_url
      type  = "String"
    }

    "/core-service/BREVO_API_KEY" = {
      value = var.brevo_api_key
      type  = "SecureString"
    }

    "/core-service/SERVER_FIXED_TOKEN" = {
      value = var.server_fixed_token
      type  = "SecureString"
    }

    "/core-service/SESSION_TOKEN_SECRET_KEY" = {
      value = var.session_token_secret_key
      type  = "SecureString"
    }

    "/core-service/DATABASE_SSL_CERT_PATH" = {
      value = var.database_ssl_cert_path
      type  = "SecureString"
    }

    "/core-service/DATABASE_URL" = {
      value = var.database_url
      type  = "SecureString"
    }
  }
}

