terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.chart_version
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 600

  # One internet-facing NLB fronts every Ingress in the cluster — same
  # controller as kind, so the app's Ingress manifests work unchanged.
  # TLS terminates at the NLB with the ACM cert; decrypted traffic lands on
  # nginx's plain HTTP port (targetPorts.https -> http).
  values = [yamlencode({
    controller = {
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type"      = "nlb"
          "service.beta.kubernetes.io/aws-load-balancer-scheme"    = "internet-facing"
          "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"  = var.certificate_arn
          "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" = "443"
        }
        targetPorts = {
          https = "http"
        }
      }
    }
  })]
}

# The NLB hostname only exists after the cloud controller provisions it;
# helm wait covers pod readiness, not LB provisioning, so poll the Service.
data "kubernetes_service" "controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}
