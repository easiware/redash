#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
red=$(tput setaf 1)
blue=$(tput setaf 4)
white=$(tput setaf 7)

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ 🟡  Build and push Docker image in Sacelway ┃"
echo "┠─────────────────────────────────────────────┨"
if ! [ $# -eq 1 ]; then
  echo "$red┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$red┃$white 🔥FATAL ERROR: No arguments supplied for environment ${bold}preview/staging/production${normal}"
  echo "$red┠────────────────────────────────────────────"
  echo "$red┃$white $ ./deploy.sh ${bold}preview${normal}"
  echo "$red┃$white $ ./deploy.sh ${bold}staging${normal}"
  echo "$red┃$white $ ./deploy.sh ${bold}production${normal}"
  echo "$red┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$normal"
  exit 1
fi

ENV=$1
RG_SCW_URI=rg.fr-par.scw.cloud
REGISTERY_URI=""

if [ "$ENV" == "preview" ]; then
  REGISTERY_URI=$RG_SCW_URI/easiware-start-registry-preview
fi
if [ "$ENV" == "staging" ]; then
  REGISTERY_URI=$RG_SCW_URI/easiware-start-registry-staging
fi
if [ "$ENV" == "production" ]; then
  REGISTERY_URI=$RG_SCW_URI/easiware-start-registry-production
fi

if [ "$REGISTERY_URI" == "" ]; then
  echo "$red┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$red┃$white 🔥FATAL ERROR: No REGISTERY_URI for arguments supplied for environment ${bold}$1${normal}"
  echo "$red┠────────────────────────────────────────────"
  echo "$red┃$white $ ./deploy.sh ${bold}preview${normal}"
  echo "$red┃$white $ ./deploy.sh ${bold}staging${normal}"
  echo "$red┃$white $ ./deploy.sh ${bold}production${normal}"
  echo "$red┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$normal"
  exit 1
fi

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 📞🟢 login $REGISTERY_URI"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker login $REGISTERY_URI --username $SCW_ACCESS_KEY --password-stdin <<< "$SCW_SECRET_KEY"

if ! [ $? -eq 0 ]; then
    echo "$red┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "┃$white 🔥FATAL ERROR: $bold docker login$normal"
    echo "$red┠────────────────────────────────────────────"
    echo "$red┃$white  👤 USER is [$blue$SCW_ACCESS_KEY$normal]"
    echo "$red┃$white  🔒 PWD  is [$blue$SCW_SECRET_KEY$normal]"
    echo "$red┠────────────────────────────────────────────"
    echo "$red┃$white  🤔 $red Did you read the README-EASIWARE.md ?$normal"
    echo "$red┃$white  🔒  Api-keys are mandatories, see:"
    echo "$red┃$blue      ${underline}https://www.scaleway.com/en/docs/iam/how-to/create-api-keys/$normal"
    echo "$red┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$normal"
    exit 1
fi

DATE=$(date '+%Y.%m.%d-%H.%M.%S')
DOCKER_IMG="redash:$DATE"

./build-tag-push.sh $REGISTERY_URI $DOCKER_IMG

if ! [ $? -eq 0 ]; then
#    docker logout $REGISTERY_URI
    exit 1
fi

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "┃ 📞 🔴 Logout $REGISTERY_URI"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker logout $REGISTERY_URI

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ 😀  Redash Docker image pushed   ┃"
echo "┠──────────────────────────────────┨"
echo "┃ ✅ ${blue}${bold}$REGISTERY_URI${normal}"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"

exit 0
