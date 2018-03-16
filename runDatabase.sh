#!/usr/bin/bash

docker-compose -f compose-database-only.yml up -d mysql
docker-compose -f compose-database-only.yml up -d neo4j
docker-compose -f compose-database-only.yml up -d mongo
docker-compose -f compose-database-only.yml up -d redis
