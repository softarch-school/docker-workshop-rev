#!/bin/bash

REGISTRY_DB=$(pwd)/registry-db

exec \
docker run  \
    -p 5000:5000  \
    -v $REGISTRY_DB:/var/lib/registry  \
    registry
