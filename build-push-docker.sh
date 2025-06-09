#!/bin/bash
set -euo pipefail

declare -a envs=("staging" "production")

img="redash:$(date '+%Y.%m.%d-%H.%M.%S')"

echo "🐳 Build Docker image $img"
docker build --pull --rm --platform="linux/amd64" -f "Dockerfile" -t "$img" "."

for env in "${envs[@]}"; do
  rg="rg.fr-par.scw.cloud/easiware-start-registry-$env"

  echo "🏷️ Tag Docker image $img for $env"
  docker tag "$img" "$rg"/"$img"
done

for env in "${envs[@]}"; do
  rg="rg.fr-par.scw.cloud/easiware-start-registry-$env"

  # Set SCW_ACCESS_KEY and SCW_SECRET_KEY
  # https://www.scaleway.com/en/docs/iam/how-to/create-api-keys/
  echo "📞 login $rg"
  docker login "$rg" --username "$SCW_ACCESS_KEY" --password-stdin <<<"$SCW_SECRET_KEY"

  trap 'echo "🔥ERROR: Docker build failed"; docker logout "$rg"; exit 1' ERR

  echo "📤 Push Docker image $img to $rg"
  docker push "$rg"/"$img"

  echo "📞 Logout $rg"
  docker logout "$rg"

  echo "😀 Redash Docker image pushed to $rg"
done
