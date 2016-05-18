#!/bin/bash

set -e -x

echo "Finalizing production deployment..."

echo $CF_API_ENDPOINT
echo $CF_USER
echo $CF_PWD
echo $CF_ORG
echo $CF_SPACE
echo $CF_MANIFEST_HOST

# get latest CF CLI
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
./cf --version

./cf login -a ${CF_API_ENDPOINT} -u ${CF_USER} -p ${CF_PWD} -o ${CF_ORG} -s ${CF_SPACE} --skip-ssl-validation

./cf apps | grep ${CF_HOST} | cut -d" " -f1 > current-apps.txt

cat current-apps.txt

