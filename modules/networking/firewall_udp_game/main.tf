resource "aws_security_group" "this" {
  name        = var.name
  description = "Allow UDP 10000-10255 for game traffic"

  ingress {
    from_port   = 10000
    to_port     = 10255
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
