provider "aws" {
  region = "us-east-2"
}

/* --- ECR Creation --- */

module "core_service_ecr" {
  source = "../../modules/ecr"
  name   = "core-service"
}

/* --- GitHub Access ---  */

module "github_oidc" {
  source = "../../modules/github_oidc"
}

module "core_service_ci_role" {
  source = "../../modules/iam_github_actions_role"

  name               = "github-actions-core-service"
  oidc_provider_arn  = module.github_oidc.arn
  ecr_repository_arn = module.core_service_ecr.repository_arn

  github_org    = "FeedTheRealm-org"
  github_repo   = "core-service"
  github_branch = "main"
}

/* --- EC2 Creation --- */

module "ec2_role" {
  source = "../../modules/iam_ec2_role"

  name   = "generic-ec2-role"
  ssm_parameter_path = "/core-service/*"
}

module "http_sg" {
  source = "../../modules/security_group_http"

  name   = "http-only"
}

module "ec2" {
  source = "../../modules/ec2"

  instance_type         = "t3.micro"
  instance_profile_name = module.ec2_role.instance_profile_name
  security_group_ids    = [module.http_sg.id]

  tags = {
    Name = "shared-ec2-runner"
  }
}

/* SSM Parameters */

module "core_service_params" {
  source = "../../modules/ssm_parameters"

  parameters = {
    "/core-service/SERVER_ENVIRONMENT" = {
      value = var.server_environment
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

