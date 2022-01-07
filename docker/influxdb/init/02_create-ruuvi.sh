#!/bin/bash
set -e

# Create a simple bucket for RuuviTag data
influx bucket create -n ruuvi --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} -r 31d

# Create auth token that allows writing to the bucket (used later)
bucketId=$(influx bucket list -n ruuvi --hide-headers | cut -c1-16)
influx v1 auth create --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} --username ruuvi-writer --no-password --write-bucket ${bucketId} -d "RuuviTag user write access to ruuvi bucket"

# Create Database Retention Policy mapping for the bucket (required for V1 writes to work)
influx v1 dbrp create --db ruuvi --rp autogen --bucket-id ${bucketId} --default

# Setting the password is done manually afterwards
# influx v1 auth set-password --username ruuvi-writer --password <PasswordToSet>
