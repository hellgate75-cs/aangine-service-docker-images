#!/bin/sh
FOLDER="$(realpath "$(dirname "$0")")"

BRANCH=developer
TAG=latest

LOGGED_IN="no"
GATEWAY="172.10.0.1"
DNS_PREFIX="172.10.0."

function cleanUp() {
	if [ "" != "$(docker ps -a|grep aangine-consul-cluster-test-1)" ]; then
		docker stop aangine-consul-cluster-test-1
		if [ "" != "$(docker ps -a|grep aangine-consul-cluster-test-1)" ]; then
			docker rm -f aangine-consul-cluster-test-1
		fi
	fi

	if [ "" != "$(docker ps -a|grep aangine-consul-cluster-test-2)" ]; then
		docker stop aangine-consul-cluster-test-2
		if [ "" != "$(docker ps -a|grep aangine-consul-cluster-test-2)" ]; then
			docker rm -f aangine-consul-cluster-test-2
		fi
	fi

	if [ "" != "$(docker ps -a|grep aangine-consul-cluster-test-3)" ]; then
		docker stop aangine-consul-cluster-test-3
		if [ "" != "$(docker ps -a|grep aangine-consul-cluster-test-3)" ]; then
			docker rm -f aangine-consul-cluster-test-3
		fi
	fi
	
	if [ "" != "$(docker ps -a|grep aangine-cluster-bind-dns)" ]; then
		docker stop aangine-cluster-bind-dns
		if [ "" != "$(docker ps -a|grep aangine-cluster-bind-dns)" ]; then
			docker rm -f aangine-cluster-bind-dns
		fi
	fi

	if [ "" != "$(docker volume ls|grep aangine_consul_volume_1)" ]; then
		docker volume rm -f aangine_consul_volume_1
	fi

	if [ "" != "$(docker volume ls|grep aangine_consul_volume_2)" ]; then
		docker volume rm -f aangine_consul_volume_2
	fi

	if [ "" != "$(docker volume ls|grep aangine_consul_volume_3)" ]; then
		docker volume rm -f aangine_consul_volume_3
	fi

	if [ "" != "$(docker volume ls|grep aangine_bind_volume)" ]; then
		docker volume rm -f aangine_bind_volume
	fi
	
	if [ "" != "$(docker network ls|grep consul_sample_cluster_network)" ]; then
		docker network rm consul_sample_cluster_network
	fi
	
#	docker swarm leave --force 2>&1 > /dev/null

#	if [ "" != "$(docker network ls|grep docker_gwbridge)" ]; then
#		docker network rm docker_gwbridge
#	fi
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

#docker swarm init 2>&1 > /dev/null

# --internal  --attachable \
docker network create --internal  --attachable \
 --gateway $GATEWAY --subnet ${DNS_PREFIX}0/16 \
 --opt com.docker.network.driver.mtu=1200 \
 consul_sample_cluster_network

docker volume create aangine_bind_volume
docker volume create aangine_consul_volume_1
docker volume create aangine_consul_volume_2
docker volume create aangine_consul_volume_3
BIND_DNS_IP="${DNS_PREFIX}2"
docker run -d --rm --name aangine-cluster-bind-dns \
 --network consul_sample_cluster_network \
 --hostname aangine-bind-dns \
 --ip ${BIND_DNS_IP} --dns ${BIND_DNS_IP} \
  -p 53:53 -p 53:53/udp \
  --mount 'source=aangine_bind_volume,target=//data' \
  -e 'ZONE_NAME=dns.sample.com' \
  -e 'FORWARDERS=8.8.8.8;8.8.4.4;192.168.0.1'
  bind9:latest
#docker run -d --rm --name aangine-cluster-bind-dns \
# --network consul_sample_cluster_network \
# --hostname aangine-bind-dns \
# --ip ${BIND_DNS_IP} --dns ${BIND_DNS_IP} \
#  -p 53:53/udp -p 8099:10000 \
#  --mount 'source=aangine_bind_volume,target=//data' \
#  -e 'ROOT_PASSWORD=Aangine1234@' \
#  sameersbn/bind:latest
sleep 30
OPTIONS="--dns=10.0.0.10 --dns=10.0.0.11 --dns-search=example.com --dns-opt=use-vc"
HOSTS_LIST="cluster-aangine-consul-1.dns.sample.com,cluster-aangine-consul-2.dns.sample.com,cluster-aangine-consul-3.dns.sample.com"
DNS_IP="$(docker exec aangine-cluster-bind-dns ifconfig eth0|grep inet|awk 'BEGIN {FS=OFS=" "}{print $2}')"
docker run -d --rm --name aangine-consul-cluster-test-1 -p '8500:8500/tcp' -p '53:53/tcp' \
--network consul_sample_cluster_network --dns ${BIND_DNS_IP} --hostname cluster-aangine-consul-1 \
-e DOMAIN=custom-aangine -e IS_CLUSTERED=yes -e NO_CHECK_NODES=no \
-e COMMA_SEPARATED_NODES_LIST=$HOSTS_LIST -e USE_CUSTOM_CONFIG=no \
 --mount 'source=aangine_consul_volume_1,target=//consul/data' registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/consul/${BRANCH}:${TAG}
sleep 20
docker run -d --rm --name aangine-consul-cluster-test-2 -p '8500:8500/tcp' -p '53:53/tcp' \
--network consul_sample_cluster_network --dns ${BIND_DNS_IP} --hostname cluster-aangine-consul-2 \
-e DOMAIN=custom-aangine -e IS_CLUSTERED=yes -e NO_CHECK_NODES=no \
-e COMMA_SEPARATED_NODES_LIST=$HOSTS_LIST -e USE_CUSTOM_CONFIG=no \
 --mount 'source=aangine_consul_volume_2,target=//consul/data' registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/consul/${BRANCH}:${TAG}
sleep 20
docker run -d --rm --name aangine-consul-cluster-test-3 -p '8500:8500/tcp' -p '53:53/tcp' \
--network consul_sample_cluster_network --dns ${BIND_DNS_IP} --hostname cluster-aangine-consul-3 \
-e DOMAIN=custom-aangine -e IS_CLUSTERED=yes -e NO_CHECK_NODES=no \
-e COMMA_SEPARATED_NODES_LIST=$HOSTS_LIST -e USE_CUSTOM_CONFIG=no \
 --mount 'source=aangine_consul_volume_3,target=//consul/data' registry.gitlab.com/aangine/kubernetes/aangine-service-docker-images/consul/${BRANCH}:${TAG}
if [ "yes" = "$LOGGED_IN" ]; then
	docker logout $DOCKER_REPO_URL
fi
echo " "
echo " "
echo "You can obtain information about the node at:"
echo "docker logs -f aangine-consul-cluster-test-1"
echo "docker logs -f aangine-consul-cluster-test-2"
echo "docker logs -f aangine-consul-cluster-test-3"
echo "docker logs -f aangine-cluster-bind-dns"
echo " "
echo "BIND DNS Web UI is available at:"
echo "http://${DNS_IP}:8099"
echo " "
echo "COLSUL Web UI is available at: "
IP="$(docker exec aangine-consul-cluster-test-1 ifconfig eth0|grep inet|awk 'BEGIN {FS=OFS=":"}{print $2}'|awk 'BEGIN {FS=OFS=" "}{print $1}')"
echo "http://${IP}:8500"
IP="$(docker exec aangine-consul-cluster-test-2 ifconfig eth0|grep inet|awk 'BEGIN {FS=OFS=":"}{print $2}'|awk 'BEGIN {FS=OFS=" "}{print $1}')"
echo "http://${IP}:8500"
IP="$(docker exec aangine-consul-cluster-test-3 ifconfig eth0|grep inet|awk 'BEGIN {FS=OFS=":"}{print $2}'|awk 'BEGIN {FS=OFS=" "}{print $1}')"
echo "http://${IP}:8500"
echo " "
echo " "
echo "In order to stop and remove the container run:"
echo "docker stop aangine-consul-cluster-test-1"
echo "docker stop aangine-consul-cluster-test-2"
echo "docker stop aangine-consul-cluster-test-3"
echo "docker stop aangine-cluster-bind-dns"
echo " "
echo " "
echo "In order to remove the container volumes after the containers, run:"
echo "docker volume rm -f aangine_consul_volume_1"
echo "docker volume rm -f aangine_consul_volume_2"
echo "docker volume rm -f aangine_consul_volume_3"
echo " "
echo " "
echo "In order to remove the container network after the containers and volumes, run:"
echo "docker network rm consul_sample_cluster_network"
echo " "
echo " "
echo "Or simply run the full automation purge procedure as follow:"
echo "./test-3-clustered-containers.sh -d"

exit 0