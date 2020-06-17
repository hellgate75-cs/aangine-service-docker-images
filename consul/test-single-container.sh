#!/bin/sh
FOLDER="$(realpath "$(dirname "$0")")"

BRANCH=development
TAG=latest

LOGGED_IN="no"

function cleanUp() {
	if [ "" != "$(docker ps -a|grep aangine-consul-test)" ]; then
		docker stop aangine-consul-test
	fi

	if [ "" != "$(docker volume ls|grep aangine_consul_volume)" ]; then
		docker volume rm -f aangine_consul_volume
	fi
}

if [ "-d" = "$1" ]; then
	echo "Destroying sample ..."
	cleanUp
	exit 0
fi


if [ -e $FOLDER/.env ]; then
	source $FOLDER/.env
	docker login -u $DOCKER_REPO_USER -p $DOCKER_REPO_PASSWORD $DOCKER_REPO_URL 2> /dev/null
	LOGGED_IN="yes"
fi

if [ "" != "$1" ]; then
	BRANCH="$1"
fi

if [ "" != "$2" ]; then
	TAG="$2"
fi

cleanUp

docker volume create aangine_consul_volume

docker run -d --rm --name aangine-consul-test -e "HTTP_PORT=8501" -p '8501:8501/tcp' -p '53:53/tcp' \
-e DOMAIN=custom-aangine -e IS_CLUSTERED=no -e NO_CHECK_NODES=no \
-e COMMA_SEPARATED_NODES_LIST= -e USE_CUSTOM_CONFIG=no --hostname test-aangine-consul \
 --mount 'source=aangine_consul_volume,target=//consul/data' registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/consul/${BRANCH}:${TAG}
#docker logs -f aangine-consul-test
if [ "yes" = "$LOGGED_IN" ]; then
	docker logout $DOCKER_REPO_URL
fi
echo " "
echo " "
echo "You can obtain information about the node at:"
echo "docker logs -f aangine-consul-test"
echo "COLSUL Web UI is available at: http://localhost:8500"
echo " "
echo " "
echo "In order to stop and remove the container run:"
echo "docker stop aangine-consul-test"
echo " "
echo " "
echo "In order to remove the container volume after the container, run:"
echo "docker volume rm -f aangine_consul_volume"
echo " "
echo " "
echo "Or simply run the full automation purge procedure as follow:"
echo "./test-single-container.sh -d"

exit 0