resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile   = var.instance_profile_name
  vpc_security_group_ids = var.security_group_ids

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region                = var.aws_region
    ecr_registry              = var.ecr_registry
    environment               = var.environment
    nomad_bootstrap_expect    = var.nomad_bootstrap_expect
    nomad_role                = var.nomad_role
    nomad_server_private_ips  = var.nomad_server_private_ips
    nomad_version             = var.nomad_version
    consul_version            = var.consul_version
    consul_role               = var.consul_role
    consul_server_private_ips = var.consul_server_private_ips
  })

  tags = var.tags
}

