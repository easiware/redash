#!/bin/bash
set -euo pipefail

ENV="${1:-}"
TAG="${2:-$(date '+%Y.%m.%d-%H.%M.%S')}"

if [[ "$ENV" != "preview" && "$ENV" != "staging" && "$ENV" != "production" ]]; then
  echo "🔥ERROR: Invalid environment"
  echo "Expected: preview/staging/production"
  echo "Received: $ENV"
  exit 1
fi

echo "🟡 Build and push Docker image in $ENV"

REGISTRY="rg.fr-par.scw.cloud/easiware-start-registry-$ENV"

# Set SCW_ACCESS_KEY and SCW_SECRET_KEY
# https://www.scaleway.com/en/docs/iam/how-to/create-api-keys/
echo "📞🟢 login $REGISTRY"
docker login "$REGISTRY" --username "$SCW_ACCESS_KEY" --password-stdin <<<"$SCW_SECRET_KEY"

trap 'echo "🔥ERROR: Docker build failed"; docker logout "$REGISTRY"; exit 1' ERR

DOCKER_IMG="redash:$TAG"
LOWERCASE_DOCKER_REF=$(echo "$DOCKER_IMG" | tr '[:upper:]' '[:lower:]')

echo "🐳 Build Docker image $LOWERCASE_DOCKER_REF"
docker build --pull --rm -f "Dockerfile" -t "$LOWERCASE_DOCKER_REF" "."

echo "🏷️ Tag Docker image $LOWERCASE_DOCKER_REF"
docker tag "$DOCKER_IMG" "$REGISTRY"/"$LOWERCASE_DOCKER_REF"

echo "📤 Push Docker image $DOCKER_IMG to $REGISTRY"
docker push "$REGISTRY"/"$LOWERCASE_DOCKER_REF"

echo "📞🔴 Logout $REGISTRY"
docker logout "$REGISTRY"

echo "😀 Redash Docker image pushed to $REGISTRY"
