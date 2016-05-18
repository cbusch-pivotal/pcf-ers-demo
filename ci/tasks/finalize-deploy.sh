#!/bin/bash

set -e

echo "Finalizing production deployment..."

# required
versionFile=

# optional
hostname=$CF_HOST # default to env variable from pipeline

while [ $# -gt 0 ]; do
  case $1 in
    -v | --version-file )
      versionFile=$2
      shift
      ;;
    * )
      echo "Unrecognized option: $1" 1>&2
      exit 1
      ;;
  esac
  shift
done

error_and_exit() {
  echo $1 >&2
  exit 1
}

if [ ! -f "$versionFile" ]; then
  error_and_exit "missing version file: $versionFile"
fi

# copy the war file to the output directory
version=`cat $versionFile`
appName="${hostname}-${version//\./-}"

# get latest CF CLI
curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx
./cf --version

./cf login -a ${CF_API_ENDPOINT} -u ${CF_USER} -p ${CF_PWD} -o ${CF_ORG} -s ${CF_SPACE} --skip-ssl-validation

DEPLOYED_APPS=$(./cf apps | grep ${hostname} | cut -d" " -f1)
#echo $DEPLOYED_APPS

# Map app version onto main app route and scale the app to support traffic
# cf map-route attendees-0-0-5 cfapps.io -n attendees
echo "map ${appName} to route ${hostname}.${CF_DOMAIN}"
#./cf map-route $appName $CF_DOMAIN -n $hostname
# cf scale attendees-0-0-5 -i 2
echo "scaling up..."
#./cf scale $appName -i 2

# Scale down, unmap routes, and remove old versions of app, except a basename app = attendees
if [ ! -z "$DEPLOYED_APPS" -a "$DEPLOYED_APPS" != " " -a "$DEPLOYED_APPS" != "$appName" ]; then
  echo "Performing zero-downtime cutover to $hostname"

  while read -r line 
  do
    if [ ! -z "$line" -a "$line" != " " -a "$line" != "$appName" -a "$line" != "$hostname"]; then 
      echo "Scaling down, unmapping and removing app: $line"
      #./cf scale "$line" -i 1
      #./cf unmap-route "$line" $CF_DOMAIN -n $hostname
      #./cf delete "$line" -f 
    else
      echo "Skipping $line" 
    fi
  done <<<"$DEPLOYED_APPS" 
fi
