#!/bin/bash
docker run --tmpfs /tmp -p 9080:8080 --env MONGO_HOST=${MONGO_HOST} $1