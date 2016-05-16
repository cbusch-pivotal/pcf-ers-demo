#!/usr/bin/env bash

set -e -x

fly -t ccb login -c http://192.168.100.4:8080
fly -t ccb set-pipeline --pipeline pcf-ers-demo --config pipeline.yml --load-vars-from .cf-env.yml
fly -t ccb unpause-pipeline --pipeline pcf-ers-demo

