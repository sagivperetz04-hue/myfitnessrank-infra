terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
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

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = "argocd"
  create_namespace = true

  # HA is overkill for a 2-node learning cluster; single replicas keep RAM free
  values = [yamlencode({
    controller = { replicas = 1 }
    server     = { replicas = 1 }
    repoServer = { replicas = 1 }
  })]
}
