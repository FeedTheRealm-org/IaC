resource "aws_security_group" "nomad" {
  name        = var.name
  description = "Nomad cluster"

  # TODO: evaluate adding new ingress to 4646 with cidr_blocks (to access UI from specific IP range)

  # Nomad API
  ingress {
    description = "Nomad HTTP API"
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  # RPC
  ingress {
    description = "Nomad RPC"
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    self        = true
  }

  # Serf gossip TCP
  ingress {
    description = "Nomad Serf TCP"
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    self        = true
  }

  # Serf gossip UDP
  ingress {
    description = "Nomad Serf UDP"
    from_port   = 4648
    to_port     = 4648
    protocol    = "udp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

