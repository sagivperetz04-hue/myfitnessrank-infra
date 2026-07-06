# The create-once secrets the app expects in each environment namespace —
# the EKS equivalent of what ./start generates on kind. Values are random,
# generated once, and live only in Terraform state (acceptable for this
# environment; External Secrets + Secrets Manager is the production upgrade).
# ArgoCD never manages secrets, so nothing here fights the GitOps sync.

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

locals {
  namespaces = [for env in var.environments : "myfitnessrank-${env}"]

  db_secrets = {
    "fitrank-db-credentials"      = { username = "fitrank", database = "fitrank" }
    "auth-db-credentials"         = { username = "fitauth", database = "fitauth" }
    "leaderboards-db-credentials" = { username = "leaderboards", database = "leaderboards" }
  }

  # namespace × db-secret pairs
  ns_db = { for pair in setproduct(local.namespaces, keys(local.db_secrets)) :
  "${pair[0]}/${pair[1]}" => { namespace = pair[0], name = pair[1] } }
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

resource "random_password" "db" {
  for_each = local.ns_db
  length   = 32
  special  = false
}

resource "kubernetes_secret" "db" {
  for_each = local.ns_db
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }
  data = {
    username = local.db_secrets[each.value.name].username
    password = random_password.db[each.key].result
    database = local.db_secrets[each.value.name].database
  }
  depends_on = [kubernetes_namespace.env]
}

resource "random_password" "jwt" {
  for_each = toset(local.namespaces)
  length   = 64
  special  = false
}

resource "kubernetes_secret" "jwt" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "jwt-signing-key"
    namespace = each.value
  }
  data = {
    "signing-key" = random_password.jwt[each.value].result
  }
  depends_on = [kubernetes_namespace.env]
}

# Fernet requires exactly 32 url-safe-base64 bytes; b64_url of 32 random bytes
# is 43 chars, plus '=' padding makes the 44-char key Python expects.
resource "random_id" "fernet" {
  for_each    = toset(local.namespaces)
  byte_length = 32
}

resource "kubernetes_secret" "fernet" {
  for_each = toset(local.namespaces)
  metadata {
    name      = "leaderboards-enc-key"
    namespace = each.value
  }
  data = {
    "fernet-key" = "${random_id.fernet[each.value].b64_url}="
  }
  depends_on = [kubernetes_namespace.env]
}

# Placeholder SMTP credentials so the prod leaderboards pod starts; mail sends
# fail gracefully (logged) until real values are set out-of-band:
#   kubectl -n myfitnessrank-prod delete secret leaderboards-smtp-credentials
#   kubectl -n myfitnessrank-prod create secret generic leaderboards-smtp-credentials \
#     --from-literal=user=... --from-literal=password=...
# (then remove this resource from state or mark it ignored).
resource "kubernetes_secret" "smtp" {
  metadata {
    name      = "leaderboards-smtp-credentials"
    namespace = "myfitnessrank-prod"
  }
  data = {
    user     = "placeholder@example.com"
    password = "placeholder"
  }
  depends_on = [kubernetes_namespace.env]

  lifecycle {
    ignore_changes = [data]
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
