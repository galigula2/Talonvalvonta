#!/bin/bash
set -e

# Create a simple bucket for telegraf data
influx bucket create -n telegraf --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} -r 31d

# Create auth token that allows writing to the bucket (used later)
bucketId=$(influx bucket list -n telegraf --hide-headers | cut -c1-16)
influx auth create --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} --write-bucket ${bucketId} -d "Telegraf user write access to telegraf bucket"