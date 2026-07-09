# Environment namespaces, the cluster StorageClass, and the one secret ESO
# does not own (grafana admin — monitoring-only, rebuilt with the cluster).
# The app's secrets now come from Secrets Manager via External Secrets
# Operator: values live in live/global/app-secret-values (they survive
# teardowns), the ExternalSecret manifests in the app repo (helm/app-secrets).

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
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

# Default StorageClass for the cluster. EKS 1.36 drops the in-tree
# kubernetes.io/aws-ebs provisioner (the vestigial gp2 class is dead), and the
# EBS CSI addon ships no default class — so the app's postgres PVCs, which set
# no storageClassName, have nothing to bind to. Provide an encrypted gp3 class
# via the CSI driver and mark it default. WaitForFirstConsumer keeps the volume
# in the same AZ as the pod that triggers it.
resource "kubernetes_storage_class" "gp3_default" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}

locals {
  namespaces = [for env in var.environments : "myfitnessrank-${env}"]
}

resource "kubernetes_namespace" "env" {
  for_each = toset(local.namespaces)
  metadata {
    name = each.value
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "random_password" "grafana" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = "monitoring"
  }
  data = {
    admin-user     = "admin"
    admin-password = random_password.grafana.result
  }
  depends_on = [kubernetes_namespace.monitoring]
}
