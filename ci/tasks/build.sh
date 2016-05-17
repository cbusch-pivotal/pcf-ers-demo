#!/bin/bash

set -e -x

#pushd source-code
#  ./mvnw clean package
#popd

#cp source-code/target/pcf-ers-demo-0.0.1.jar build-output/.

# FROM PCF-DEMO REPO ----

# args
inputDir=  outputDir=  versionFile=  artifactId=  packaging=

while [ $# -gt 0 ]; do
  case $1 in
    -i | --input-dir )
      inputDir=$2
      shift
      ;;
    -o | --output-dir )
      outputDir=$2
      shift
      ;;
    -v | --version-file )
      versionFile=$2
      shift
      ;;
    -a | --artifactId )
      artifactId=$2
      shift
      ;;
    -p | --packaging )
      packaging=$2
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

if [ ! -d "$inputDir" ]; then
  error_and_exit "missing input directory: $inputDir"
fi
if [ ! -d "$outputDir" ]; then
  error_and_exit "missing output directory: $outputDir"
fi
if [ ! -f "$versionFile" ]; then
  error_and_exit "missing version file: $versionFile"
fi
if [ -z "$artifactId" ]; then
  error_and_exit "missing artifactId!"
fi
if [ -z "$packaging" ]; then
  error_and_exit "missing packaging!"
fi

version=`cat $versionFile`
artifactName="${artifactId}-${version}.${packaging}"

cd $inputDir
./mvnw clean package -DversionNumber=$version

# Copy jar file to concourse output folder
pwd
ls -al target
ls -al ../$outputDir

cp target/$artifactName ../$outputDir/$artifactName

