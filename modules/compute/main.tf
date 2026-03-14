resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile   = var.instance_profile_name
  vpc_security_group_ids = var.security_group_ids

  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -e

yum install -y docker unzip jq awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

# Install Nomad
curl -fsSL https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_amd64.zip -o /tmp/nomad.zip
unzip -o /tmp/nomad.zip -d /usr/local/bin
chmod +x /usr/local/bin/nomad

# Create nomad user
useradd --system --home /etc/nomad.d --shell /bin/false nomad || true

mkdir -p /etc/nomad.d /opt/nomad/data
chown -R nomad:nomad /etc/nomad.d /opt/nomad/data

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Base Nomad config
cat <<NOMADCFG >/etc/nomad.d/nomad.hcl
datacenter = "dc1"
region     = "global"
data_dir   = "/opt/nomad/data"
bind_addr  = "0.0.0.0"

advertise {
  http = "$LOCAL_IP:4646"
  rpc  = "$LOCAL_IP:4647"
  serf = "$LOCAL_IP:4648"
}
NOMADCFG

# Role specific config
if [ "${var.nomad_role}" = "server" ]; then
cat <<NOMADCFG >>/etc/nomad.d/nomad.hcl
server {
  enabled          = true
  bootstrap_expect = ${var.nomad_bootstrap_expect}
}
NOMADCFG
else
if [ "${join(" ", var.nomad_server_private_ips)}" = "" ]; then
  echo "Nomad client bootstrap failed: nomad_server_private_ips is empty."
  exit 1
fi

cat <<NOMADCFG >>/etc/nomad.d/nomad.hcl
client {
  enabled = true
  servers = [${join(", ", [for ip in var.nomad_server_private_ips : format("\"%s:4647\"", ip)])}]
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
NOMADCFG
fi

chown nomad:nomad /etc/nomad.d/nomad.hcl
chmod 640 /etc/nomad.d/nomad.hcl

# Systemd service
cat <<'SYSTEMD' >/etc/systemd/system/nomad.service
[Unit]
Description=Nomad
After=network-online.target docker.service
Requires=docker.service
Wants=network-online.target

[Service]
User=nomad
Group=nomad
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.d
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable nomad
systemctl start nomad

# Datadog setup
DD_API_KEY=$(aws ssm get-parameter \
  --name "/monitoring/dd_api_key" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region ${var.aws_region})

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

