#!/usr/bin/env bash

set -e

# Build the project and docker images
mvn clean install -DskipTests -Dmaven.test.skip=true

# docker-machine doesn't exist in Linux, assign default ip if it's not set
export DOCKER_IP=${DOCKER_IP:-127.0.0.1}

# Remove existing containers
docker-compose stop
docker-compose rm -f

# Start the config service first and wait for it to become available
docker-compose up -d config-service

while [ -z ${CONFIG_SERVICE_READY} ]; do
  echo "Waiting for config service..."
  if [ "$(curl --silent 0.0.0.0:8888/health 2>&1 | grep -q '\"status\":\"UP\"'; echo $?)" = 0 ]; then
      CONFIG_SERVICE_READY=true;
  fi
  sleep 2
done

# Start the discovery service next and wait
docker-compose up -d discovery-service

while [ -z ${DISCOVERY_SERVICE_READY} ]; do
  echo "Waiting for discovery service..."
  if [ "$(curl --silent 0.0.0.0:8761/health 2>&1 | grep -q '\"status\":\"UP\"'; echo $?)" = 0 ]; then
      DISCOVERY_SERVICE_READY=true;
  fi
  sleep 2
done

# Start the other containers
docker-compose up -d

# Attach to the log output of the cluster
docker-compose logs
