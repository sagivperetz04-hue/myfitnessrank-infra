output "certificate_arn" {
  description = "ISSUED certificate ARN (gated on validation), consumed by ingress-nginx's NLB"
  value       = aws_acm_certificate_validation.this.certificate_arn
}
