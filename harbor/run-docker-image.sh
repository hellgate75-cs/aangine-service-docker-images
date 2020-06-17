#!/bin/sh
if [ "" = "$(docker imaage|grep hellgate75|grep harbor)" ]; then
	sh ./build-docker-image.sh
fi
DATA_FOLDER=/data
mkdir $DATA_FOLDER
docker run -d -it --restart unless-stopped --name harbor-registry -e HOSTNAME="$(hostname)" -v /input:/input -v /root:/root -v $DATA_FOLDER:/data -v /var/run/docker.sock:/var/run/docker.sock hellgate75/harbor
