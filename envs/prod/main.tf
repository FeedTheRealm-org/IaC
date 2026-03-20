provider "aws" {
  region = var.aws_region
}

/* --- ECR Creation --- */

module "core_service_ecr" {
  source     = "../../modules/container_registry"
  name       = "core-service"
  is_mutable = false
}

module "ftr_server_ecr" {
  source     = "../../modules/container_registry"
  name       = "ftr-server"
  is_mutable = true
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

module "ftr_server_ci_role" {
  source = "../../modules/identity/iam_github_actions_role"

  name               = "github-actions-ftr-server"
  oidc_provider_arn  = module.github_oidc.arn
  ecr_repository_arn = module.ftr_server_ecr.repository_arn

  github_org    = "FeedTheRealm-org"
  github_repo   = "game"
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

  name = "generic-ec2-role"
  ssm_parameter_paths = [
    "/core-service/*",
    "/ftr-server/*",
    "/monitoring/*",
    "/nomad/*",
    "/consul/*"
  ]
  ssm_write_parameter_paths = [
    "/nomad/*"
  ]
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

module "ftr_server_sg" {
  source = "../../modules/networking/firewall_udp_game"

  name = "ftr-server-udp"
}

module "nomad_sg" {
  source = "../../modules/networking/firewall_nomad"

  name                       = "nomad-internal"
  allowed_security_group_ids = [module.http_sg.id, module.ftr_server_sg.id]
}

module "consul_sg" {
  source = "../../modules/networking/firewall_consul"

  name                       = "consul-internal"
  allowed_security_group_ids = [module.nomad_sg.id]
}

module "core_nomad_server" {
  source = "../../modules/compute"

  depends_on = [module.monitoring_params]

  ami                   = var.ami
  instance_type         = var.core_nomad_server_instance_type
  ssh_key_name          = var.ssh_key_name
  instance_profile_name = module.ec2_role.instance_profile_name
  security_group_ids = [
    module.http_sg.id,
    module.nomad_sg.id,
    module.consul_sg.id,
    module.ssh_sg.id
  ] # Add `module.ssh_sg.id` only for debugging.

  environment  = var.environment
  aws_region   = var.aws_region
  ecr_registry = split("/", module.core_service_ecr.repository_url)[0]

  nomad_version          = var.nomad_version
  nomad_role             = "server"
  nomad_bootstrap_expect = 1

  consul_version = var.consul_version
  consul_role    = "server"

  tags = {
    Name = "core-nomad-server"
    Role = "nomad-server"
  }
}

module "nomad_clients" {
  for_each = var.nomad_client_nodes

  source = "../../modules/compute"

  depends_on = [module.monitoring_params, module.core_nomad_server]

  ami                   = var.ami
  instance_type         = each.value.instance_type
  ssh_key_name          = var.ssh_key_name
  instance_profile_name = module.ec2_role.instance_profile_name
  security_group_ids = concat(
    [module.nomad_sg.id, module.consul_sg.id, module.ssh_sg.id],
    each.value.enable_udp_game_traffic ? [module.ftr_server_sg.id] : []
  ) # Add `module.ssh_sg.id` only for debugging.

  environment  = var.environment
  aws_region   = var.aws_region
  ecr_registry = split("/", module.core_service_ecr.repository_url)[0]

  nomad_version            = var.nomad_version
  nomad_role               = "client"
  nomad_server_private_ips = [module.core_nomad_server.private_ip]

  consul_version            = var.consul_version
  consul_role               = "client"
  consul_server_private_ips = [module.core_nomad_server.private_ip]

  tags = {
    Name = each.value.name
    Role = "nomad-client"
  }
}

/* DNS */

module "internal_dns" {
  source = "../../modules/networking/dns"

  zone_name = "internal"
  vpc_id    = var.vpc_id

  records = {
    "nomad"        = module.core_nomad_server.private_ip
    "core-service" = module.core_nomad_server.private_ip
  }
}

/* SSM Parameters */

module "core_service_params" {
  source = "../../modules/parameter_store/ssm_parameters"

  parameters = {
    "/core-service/SERVER_ENVIRONMENT" = {
      value = var.environment
      type  = "String"
    }

    "/core-service/PUBLIC_IP" = {
      value = module.core_nomad_server.public_ip
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

    "/core-service/NOMAD_CERT_PATH" = {
      value = var.nomad_cert_path
      type  = "String"
    }

    "/core-service/FTR_SERVER_IMAGE" = {
      value = "${module.ftr_server_ecr.repository_url}:latest"
      type  = "String"
    }

    "/core-service/ASSETS_COSMETICS_BUCKET_NAME" = {
      value = module.s3_buckets["cosmetics"].bucket_name
      type  = "String"
    }

    "/core-service/ASSETS_WORLDS_BUCKET_NAME" = {
      value = module.s3_buckets["worlds"].bucket_name
      type  = "String"
    }
  }
}

module "ftr_server_params" {
  source = "../../modules/parameter_store/ssm_parameters"

  parameters = {
    "/ftr-server/CORE_SERVICE_URL" = {
      value = var.ftr_core_service_url
      type  = "String"
    }
  }
}

module "monitoring_params" {
  source = "../../modules/parameter_store/ssm_parameters"

  parameters = {
    "/monitoring/dd_api_key" = {
      value = var.dd_api_key
      type  = "SecureString"
    }
  }
}

module "nomad_params" {
  source = "../../modules/parameter_store/ssm_parameters"

  parameters = {
    "/nomad/NOMAD_ADDR" = {
      value = "https://nomad.internal:4646"
      type  = "String"
    }

    # /nomad/NOMAD_TOKEN (created dynamically in user_data)
  }
}

module "consul_params" {
  source = "../../modules/parameter_store/ssm_parameters"

  parameters = {
    "/consul/encrypt_key" = {
      value = var.consul_encrypt_key
      type  = "SecureString"
    }
  }
}

