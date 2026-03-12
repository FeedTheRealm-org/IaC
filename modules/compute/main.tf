resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = var.ssh_key_name

  iam_instance_profile = var.instance_profile_name
  vpc_security_group_ids = var.security_group_ids

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    yum install -y docker

    systemctl enable docker
    systemctl start docker

    sudo usermod -aG docker ec2-user
    newgrp docker

    DD_API_KEY=$(aws ssm get-parameter \
      --name "/monitoring/dd_api_key" \
      --with-decryption \
      --query "Parameter.Value" \
      --output text \
      --region us-east-2)

    docker run -d --name datadog-agent \
      --restart unless-stopped \
      -e DD_API_KEY=$DD_API_KEY \
      -e DD_SITE="us5.datadoghq.com" \
      -e DD_LOGS_ENABLED=true \
      -e DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true \
      -e DD_PROCESS_AGENT_ENABLED=true \
      -e DD_CONTAINER_EXCLUDE="name:datadog-agent" \
      -e DD_TAGS="env:${var.environment}" \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      -v /proc/:/host/proc/:ro \
      -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
      -v /var/lib/docker/containers:/var/lib/docker/containers:ro \
      datadog/agent:latest
  EOF

  tags = var.tags
}

