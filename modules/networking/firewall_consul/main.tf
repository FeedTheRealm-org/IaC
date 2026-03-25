resource "aws_security_group" "consul" {
  name = var.name

  # Consul HTTP API (your backend queries this)
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    self            = true
  }

  # Consul RPC
  ingress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"
    self      = true
  }

  # Consul Serf LAN (gossip between agents)
  ingress {
    from_port = 8301
    to_port   = 8301
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port = 8301
    to_port   = 8301
    protocol  = "udp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

