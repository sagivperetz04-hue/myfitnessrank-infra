# Source of truth for the app's secret values: one consolidated JSON secret
# per environment in Secrets Manager. Lives in live/global so teardowns never
# touch it — unlike the old in-cluster random secrets, values persist across
# cluster rebuilds. Values are seeded randomly once; ignore_changes lets you
# overwrite individual keys in the console/CLI (e.g. real SMTP credentials)
# without terraform fighting back. ESO syncs them into the cluster.
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

locals {
  db_identities = {
    fitrank      = { username = "fitrank", database = "fitrank" }
    auth         = { username = "fitauth", database = "fitauth" }
    leaderboards = { username = "leaderboards", database = "leaderboards" }
  }

  env_db = { for pair in setproduct(var.environments, keys(local.db_identities)) :
  "${pair[0]}/${pair[1]}" => { env = pair[0], db = pair[1] } }
}

resource "random_password" "db" {
  for_each = local.env_db
  length   = 32
  special  = false
}

resource "random_password" "jwt" {
  for_each = toset(var.environments)
  length   = 64
  special  = false
}

# Fernet requires exactly 32 url-safe-base64 bytes; b64_url of 32 random bytes
# is 43 chars, plus '=' padding makes the 44-char key Python expects.
resource "random_id" "fernet" {
  for_each    = toset(var.environments)
  byte_length = 32
}

resource "aws_secretsmanager_secret" "app" {
  for_each = toset(var.environments)
  name     = "${var.project}/${each.value}/app"
}

resource "aws_secretsmanager_secret_version" "app" {
  for_each  = toset(var.environments)
  secret_id = aws_secretsmanager_secret.app[each.value].id

  secret_string = jsonencode(merge(
    merge([for db, identity in local.db_identities : {
      "${db}_db_username" = identity.username
      "${db}_db_password" = random_password.db["${each.value}/${db}"].result
      "${db}_db_database" = identity.database
    }]...),
    {
      jwt_signing_key = random_password.jwt[each.value].result
      fernet_key      = "${random_id.fernet[each.value].b64_url}="
      # Placeholders — set the real values once in the console/CLI; they
      # persist across every teardown from then on
      smtp_user     = "placeholder@example.com"
      smtp_password = "placeholder"
    }
  ))

  lifecycle {
    ignore_changes = [secret_string, version_stages]
  }
}
