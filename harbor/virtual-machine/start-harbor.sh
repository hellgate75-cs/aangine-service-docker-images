#!/bin/bash
if [ "" = "$(docker ps -a|grep harbor-core)" ]; then
	echo "HARBOR: Harbor doesn't exists!!"
	echo "HARBOR: Abort!"
	exit 1
else
	echo "HARBOR: Harbor Stack created ... starting services"
	cd /root/platform
	echo "HARBOR: Starting platform compose ..."
	docker-compose -f ./docker-compose.yml start
	cd /root/harbor
	echo "HARBOR: Starting platform compose ..."
	docker-compose -f ./docker-compose.yml start
	echo "HARBOR: Starting services ..."
	IFS=$'\n';for container in $(docker ps -a|grep -v NAME|awk 'BEGIN {FS=OFS=" "}{print $NF}'); do
		echo "HARBOR: Starting container: $container ..."
		docker start $container
		echo "HARBOR: Container: $container started!"
	done
fi
exit 0