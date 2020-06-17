#!/bin/sh
if [ "" != "$(docker image ls|grep -v REPOSITORY)" ]; then
	docker image ls|grep -v REPOSITORY|awk 'BEGIN {FS=OFS=" "}{print $3}'|xargs docker rmi
fi
