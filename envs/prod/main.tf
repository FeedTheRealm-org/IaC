provider "aws" {
  region = "us-east-2"
}

module "core_service_ecr" {
  source = "../../modules/ecr"
  name   = "core-service"
}

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
