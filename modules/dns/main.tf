resource "aws_route53_zone" "this" {
  name = var.domain

  # The zone is the stable anchor for NS delegation at the registrar; records
  # and certs come and go with the cluster, the zone should not.
  lifecycle {
    prevent_destroy = true
  }
}
