#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
SCRIPT_PATH=$(cd "${SCRIPT_PATH}" && pwd)
cd "$SCRIPT_PATH" || exit

CP_VERSION=${CP_VERSION:-7.4.1}

# check commands
command -v docker >/dev/null 2>&1 || { echo >&2 "docker is not installed. Aborting."; exit 1; }
command -v git >/dev/null 2>&1 || { echo >&2 "git is not installed. Aborting."; exit 1; }

# create directories
mkdir -p lib/csid-config-provider-gcloud
mkdir -p workspace/cache/m2
cd workspace

# checkout secret provider code
[ ! -d csid-secrets-providers ] && {
  git clone https://github.com/confluentinc/csid-secrets-providers.git
}
cd csid-secrets-providers
git pull --prune

# run a docker image to build and package the plugin
docker run -i --rm \
 -v $PWD:/code \
 -v $PWD/../cache/m2:/home/appuser/.m2 \
 confluentinc/cp-server-connect:$CP_VERSION sh -s <<-'EOF'
# within docker
cd /code
#./mvnw package -DskipTests
./mvnw clean package
EOF

# copy the package to lib directory. make sure you delete the old version in lib
rm -rf $SCRIPT_PATH/csid-config-provider-gcloud/*.zip
find ./gcloud -type f -name '*.zip' | xargs -I '{}' cp '{}' $SCRIPT_PATH/csid-config-provider-gcloud/
