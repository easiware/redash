#!/bin/bash
set -euo pipefail

declare -a ENVS=("preview" "staging" "production")

TAG="$(date '+%Y.%m.%d-%H.%M.%S')"
DOCKER_IMG="redash:$TAG"
LOWERCASE_DOCKER_REF=$(echo "$DOCKER_IMG" | tr '[:upper:]' '[:lower:]')

echo "🐳 Build Docker image $LOWERCASE_DOCKER_REF"
docker build --pull --rm --platform="linux/amd64" -f "Dockerfile" -t "$LOWERCASE_DOCKER_REF" "."

for env in "${ENVS[@]}"; do
  echo "🟡 Build and push Docker image in $env"

  REGISTRY="rg.fr-par.scw.cloud/easiware-start-registry-$env"

  # Set SCW_ACCESS_KEY and SCW_SECRET_KEY
  # https://www.scaleway.com/en/docs/iam/how-to/create-api-keys/
  echo "📞 login $REGISTRY"
  docker login "$REGISTRY" --username "$SCW_ACCESS_KEY" --password-stdin <<<"$SCW_SECRET_KEY"

  trap 'echo "🔥ERROR: Docker build failed"; docker logout "$REGISTRY"; exit 1' ERR

  echo "🏷️ Tag Docker image $LOWERCASE_DOCKER_REF"
  docker tag "$DOCKER_IMG" "$REGISTRY"/"$LOWERCASE_DOCKER_REF"

  echo "📤 Push Docker image $DOCKER_IMG to $REGISTRY"
  docker push "$REGISTRY"/"$LOWERCASE_DOCKER_REF"

  echo "📞 Logout $REGISTRY"
  docker logout "$REGISTRY"

  echo "😀 Redash Docker image pushed to $REGISTRY"
done
