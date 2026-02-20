data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type
  key_name = var.ssh_key_name

  iam_instance_profile = var.instance_profile_name
  vpc_security_group_ids = var.security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    yum install -y docker

    systemctl enable docker
    systemctl start docker

    sudo usermod -aG docker ec2-user
    newgrp docker
  EOF

  tags = var.tags
}

