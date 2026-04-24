resource "aws_eip" "this" {
  domain = "vpc"

  tags = var.tags
}

resource "aws_eip_association" "this" {
  allocation_id = aws_eip.this.id
  instance_id   = var.instance_id
}
