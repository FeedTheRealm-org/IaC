resource "aws_route53_zone" "this" {
  name = var.zone_name

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "records" {
  for_each = var.records

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.${var.zone_name}"
  type    = "A"
  ttl     = 60
  records = [each.value]
}
