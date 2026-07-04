resource "aws_route53_zone" "this" {
  name = var.domain
}

resource "aws_route53_record" "cname" {
  for_each = var.cname_records

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}
