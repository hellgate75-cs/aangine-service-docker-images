#!/bin/sh

if [ "-d" = "$1" ]; then
	if [ "" != "$(docker ps -a|grep bind9-test)" ]; then
		docker stop bind9-test
		if [ "" != "$(docker ps -a|grep bind9-test)" ]; then
			docker rm -f bind9-test
		fi
	fi
	exit 0
fi

#winpty docker run -d --rm -it --name bind9-test -p "55:53" -p "55:53/upd" bind9
winpty docker run -d --rm -it --dns 192.168.0.31 --name bind9-test -P bind9
