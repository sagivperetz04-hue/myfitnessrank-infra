# The NLB is created by the in-cluster cloud controller (Service of type
# LoadBalancer), not by Terraform, so it is located by the tags Kubernetes
# stamps on it. Route53 ALIAS records need the LB's canonical zone id, which
# only this lookup provides.
data "aws_lb" "ingress" {
  tags = {
    "kubernetes.io/service-name" = "ingress-nginx/ingress-nginx-controller"
  }

  lifecycle {
    postcondition {
      condition     = self.dns_name == var.lb_hostname
      error_message = "The NLB found by tag does not match the ingress unit's hostname output — is another cluster's LB tagged identically?"
    }
  }
}

locals {
  # apex + staging + www; prod is the apex, matching the app's ingress hosts.
  record_names = [var.domain, "staging.${var.domain}", "www.${var.domain}"]
}

resource "aws_route53_record" "site" {
  for_each = toset(local.record_names)

  zone_id = var.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress.dns_name
    zone_id                = data.aws_lb.ingress.zone_id
    evaluate_target_health = false
  }
}
