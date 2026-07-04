#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/live/us-east-1"

echo "==> Bringing up all infrastructure under live/us-east-1"
echo "==> Reminder: an applied stack bills ~\$120-160/month. ./stopinfra.sh tears it down."
echo

terragrunt run --all --non-interactive apply

echo
echo "==> Done. Meter is running - ./stopinfra.sh when you finish for the day."
