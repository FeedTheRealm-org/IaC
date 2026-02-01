provider "aws" {
  region = "us-east-2"
}

module "core_service_ecr" {
  source = "../../modules/ecr"
  name   = "core-service"
}

