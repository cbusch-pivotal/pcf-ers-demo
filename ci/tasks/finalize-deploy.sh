#!/bin/bash

set -e -x

echo "Finalizing production deployment..."

echo $API_ENDPOINT
echo $USER
echo $PW
echo $ORG
echo $SPACE
echo $CF_MANIFEST_HOST

# get latest CF CLI
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
./cf --version

./cf login -a ${API_ENDPOINT} -u ${USER} -p ${PW} -o ${ORG} -s ${SPACE} --skip-ssl-validation

./cf apps | grep ${CF_MANIFEST_HOST} | cut -d" " -f1 > current-apps.txt

cat current-apps.txt

