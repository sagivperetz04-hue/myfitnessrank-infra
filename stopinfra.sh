#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/live/us-east-1"

echo "==> Destroying all infrastructure under live/us-east-1"
echo "==> Code and Terraform state survive this - ./startinfra.sh rebuilds everything."
echo

terragrunt run --all --non-interactive destroy

echo
echo "==> Done. Nothing left billing except pennies for S3 state storage."
