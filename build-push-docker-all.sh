#!/bin/bash
set -eo pipefail

echo "🟡 Build and push Docker images in all Scaleway environments"

DATE=$(date '+%Y.%m.%d-%H.%M.%S')

./build-push-docker.sh preview "$DATE"
./build-push-docker.sh staging "$DATE"
./build-push-docker.sh production "$DATE"
