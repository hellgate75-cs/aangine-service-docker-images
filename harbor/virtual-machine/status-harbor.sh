#!/bin/bash
COMPOSE_PLATFORM="$(cd /root/platform && docker-compose -f ./docker-compose.yml ps|grep -v Name|grep -v "\\-\\-\\-")"
COMPOSE_HARBOR="$(cd /root/harbor && docker-compose -f ./docker-compose.yml ps|grep -v Name|grep -v "\\-\\-\\-")"
if [ "" = "$COMPOSE_PLATFORM" ] || [ "" = "$COMPOSE_HARBOR" ]; then
	exit 1
fi
exit 0