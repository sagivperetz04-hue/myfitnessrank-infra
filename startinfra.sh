#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/live"

# The DNS unit refuses placeholders at plan time too, but failing here is
# friendlier than a mid-apply abort with half the stack up.
if grep -q 'REPLACE-ME' global/dns/terragrunt.hcl; then
  echo "ERROR: set your real domain in live/global/dns/terragrunt.hcl first" >&2
  echo "       (also swap it into the app repo's deploy/envs/staging/frontend.yaml)" >&2
  exit 1
fi

echo "==> Bringing up all infrastructure under live/"
echo "==> Reminder: an applied stack bills ~\$120-160/month. ./stopinfra.sh tears it down."
echo

terragrunt run --all --non-interactive apply

echo
echo "==> Name servers — make sure these are set at your registrar (one-time):"
terragrunt output -json name_servers --working-dir global/dns | python3 -m json.tool

domain=$(terragrunt output -raw domain --working-dir global/dns)
echo
echo "==> Done. Meter is running - ./stopinfra.sh when you finish for the day."
echo "    prod:    https://${domain}"
echo "    staging: https://staging.${domain}"
echo "    ArgoCD:  kubectl -n argocd port-forward svc/argocd-server 8081:443"
echo "             (aws eks update-kubeconfig --name myfitnessrank first)"
