#!/bin/bash
set -e

# Create auth token that allows reading all buckets for grafana (used later)
influx auth create --org-id ${DOCKER_INFLUXDB_INIT_ORG_ID} --read-buckets -d "Grafana user read access to all buckets"
