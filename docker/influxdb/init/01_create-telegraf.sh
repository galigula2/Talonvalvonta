#!/bin/bash
set -e

influx bucket create -n telegraf --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} -r 31d
influx user create -n telegraf --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} -p $INFLUXDB_USERPWD_TELEGRAF
bucketId=$(influx bucket list -n telegraf --hide-headers | cut -c1-16)
influx auth create -u telegraf --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} --write-bucket ${bucketId} -d "Telegraf user write access to telegraf bucket"
