#!/bin/bash

REPO="mfarajpour/flask-gitops-app"

echo "Fetching images from ghcr.io/${REPO}..."
echo ""

gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/user/packages/container/${REPO##*/}/versions" \
  --jq '.[] | "\(.metadata.container.tags[]) | Updated: \(.updated_at)"' | sort -r

echo ""
echo "Tip: Use these tags for promotion"
