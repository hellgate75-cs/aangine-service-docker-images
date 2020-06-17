#!/bin/bash
cd /root/platform
docker-compose -f ./docker-compose.yml stop --remove-orphans --volumes 1>&2 /dev/null
cd /root/harbor
docker-compose -f ./docker-compose.yml stop --remove-orphans --volumes 1>&2 /dev/null
