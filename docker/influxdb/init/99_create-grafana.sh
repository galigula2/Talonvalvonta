#!/bin/bash
set -e

influx user create -n grafana --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} -p ${INFLUXDB_USERPWD_GRAFANA}
influx auth create -u grafana --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} --read-buckets -d "Grafana user read access to all buckets"
