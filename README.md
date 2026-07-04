# myfitnessrank-infra

Terraform + Terragrunt code for the AWS infrastructure behind
[myfitnessrank-app](https://github.com/sagivperetz04-hue/myfitnessrank-app).

This repo builds the **platform** (network, cluster, registry, CI identity).
Application code, Helm charts, and CI pipelines live in the app repo — nothing
here depends on them.

## Layout

```
modules/            Reusable Terraform modules (how to build a thing)
  vpc/              Network: subnets, NAT, EKS-ready tagging
  eks/              EKS cluster + managed node group (spot)
  ecr/              Container registries, one per service
  github-oidc/      IAM role assumed by GitHub Actions via OIDC (no long-lived keys)
live/               Terragrunt tree (build one of those, here, with these values)
  root.hcl          Shared config: S3 remote state (native locking), AWS provider
  us-east-1/
    vpc/  eks/  ecr/  github-oidc/
```

## Key decisions

- **Region:** us-east-1
- **State:** S3 bucket `myfitnessrank-tfstate-<account-id>`, one state file per
  unit, native S3 locking (`use_lockfile`) — no DynamoDB
- **Nodes:** t3.medium spot, cost-optimized for a learning environment
- **Environments:** staging + prod as namespaces on one cluster; dev runs
  locally on kind

## Usage

Requires: `aws` CLI (authenticated), `terraform`, `terragrunt`.

```sh
cd live/us-east-1/<unit>
terragrunt plan     # preview changes
terragrunt apply    # make AWS match the code
```

The state bucket is created automatically by Terragrunt on first run.

## Cost warning

An applied cluster bills ~$120–160/month (control plane + NAT + spot nodes +
load balancer). Destroy when idle:

```sh
cd live/us-east-1
terragrunt destroy --all
```
