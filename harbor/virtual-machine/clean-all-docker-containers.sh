#!/bin/sh
if [ "" != "$(docker ps|grep -v NAME)" ]; then
	docker ps|grep -v NAME|awk 'BEGIN {FS=OFS=" "}{print $1}'|xargs docker stop
fi
if [ "" != "$(docker ps -a|grep -v NAME)" ]; then
	docker ps -a|grep -v NAME|awk 'BEGIN {FS=OFS=" "}{print $1}'|xargs docker rm -f
fi
