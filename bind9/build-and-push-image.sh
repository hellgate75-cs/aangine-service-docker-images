#!/bin/sh
FOLDER="$(realpath "$(dirname "$0")")"

if [ "" != "$(which dos2unix)" ]; then
	dos2unix $FOLDER/.env
fi

BRANCH=developer
TAG=latest

if [ -e $FOLDER/.env ]; then
	source $FOLDER/.env
	docker login -u $DOCKER_REPO_USER -p $DOCKER_REPO_PASSWORD $DOCKER_REPO_URL 2> /dev/null
fi

if [ "" != "$1" ]; then
	TAG="$1"
fi

if [ "" != "$(docker image ls|awk 'BEGIN {FS=OFS=" "}{print $1":"$2}'| grep 'aangine'| grep "aangine-service-docker-images/bind9/${BRANCH}:${TAG}")" ]; then
	echo "Removing existing docker image for aangine-service-docker-images/bind9 rel. ${BRANCH} v. ${TAG} ..."
	docker rmi -f registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${BRANCH}:${TAG}
fi

echo "Building aangine-service-docker-images/bind9 rel. ${BRANCH} v. ${TAG} ..."
docker build --rm --force-rm --no-cache -t registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${BRANCH}:${TAG} .
EXIT=$?
if [ "0" = "$EXIT" ] || [ "127" = "$EXIT" ]; then
	if [ -e $FOLDER/.env ]; then
		docker push registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${BRANCH}:${TAG}
		if [ "" != "$DOCKER_BRANCHES" ]; then
			IFS=','; for otherBranch in $DOCKER_BRANCHES; do
				if [ "" != "${otherBranch}" ]; then
					echo "Pushing branch ${otherBranch} ..."
					docker tag "registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${BRANCH}:${TAG}"  "registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${otherBranch}:${TAG}"
					docker push "registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${otherBranch}:${TAG}"
					docker rmi "registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${otherBranch}:${TAG}"
				fi
			done
		fi
		docker logout $DOCKER_REPO_URL
		docker rmi registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/bind9/${BRANCH}:${TAG}
	fi
else
	echo "EXIT CODE=$EXIT"
	exit $EXIT
fi
exit 0
