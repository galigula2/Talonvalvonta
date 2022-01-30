#!/bin/bash
set -e

# Create a simple bucket for EnergyPulseReader data
influx bucket create -n energypulsereader --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} -r 31d

# Create auth token that allows writing to the bucket (used later)
bucketId=$(influx bucket list -n energypulsereader --hide-headers | cut -c1-16)
influx auth create --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} --write-bucket ${bucketId} --read-bucket ${bucketId} -d "EnergyPulseReader user write/read access to energypulsereader bucket"