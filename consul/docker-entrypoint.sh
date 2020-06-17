#!/bin/sh
FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "docker-entrypoint.sh {cmd} {arg1} ... {argN}"
	echo "  {cmd}    				command you want run"
	echo "  {arg1} ... {argN}		Command Arguments arg1 ... argN"
}

if [ "-h" = "$1" ] || [ "--help" = "$1" ]; then
	echo "Usage:"
	echo "$(usage)"
	echo "CONSUL: Exit!!"
	exit 0
fi

function qualifyNode() {
	CLI_RETRY=0
	BASE="$(ping -c 1 $1|grep "("|grep ttl)"
	while [ "" = "$BASE" ] && [ $CLI_RETRY -lt $CONNECTION_RETRY ]; do
		echo "Wait ..."
		sleep $RETRY_TIMEOUT_SECONDS
		let CLI_RETRY=CLI_RETRY+1
		BASE="$(ping -c 1 $1|grep "("|grep ttl)"
	done
	if [ "" = "$BASE" ]; then
		echo "unreachable"
	else
		echo "$(echo "$BASE"|awk 'BEGIN {FS=OFS="("}{print $2}'|awk 'BEGIN {FS=OFS=")"}{print $1}')"
	fi
}

echo "CONSUL: Starting Consul Container ..."

if [ "yes" != "$USE_CUSTOM_CONFIG" ]; then
	echo "CONSUL: Copying templates to folder /consul/config"
	if [ "yes" != "$IS_CLUSTERED" ]; then
		echo "CONSUL: Copting single node configuration"
		dos2unix /consul/templates/single/*
		cp -f /consul/templates/single/* /consul/config/
	else
		echo "CONSUL: Copting clustered nodes configuration"
		dos2unix /consul/templates/cluster/*
		cp -f /consul/templates/cluster/* /consul/config/
	fi
	if [ -e /consul/config/node.json ]; then
		sed -i "s/DOMAIN/$DOMAIN/g" /consul/config/node.json
		sed -i "s/NODE_NAME/$NODE_NAME/g" /consul/config/node.json
	fi
	if [ -e /consul/config/service.json ]; then
		sed -i "s/DOMAIN/$DOMAIN/g" /consul/config/service.json
		sed -i "s/NODE_NAME/$NODE_NAME/g" /consul/config/service.json
	fi
else
	echo "CONSUL: You choose to use your files in folder /consul/config"
fi
dos2unix /consul/config/*

export NODE_NAME="$(hostname)"
export IP_ADDRESS="$(ifconfig $NETWORK_DEVICE|grep inet|awk 'BEGIN {FS=OFS=":"}{print $2}'|awk 'BEGIN {FS=OFS=" "}{print $1}')"

RETRY=0

while [ "" = "$IP_ADDRESS" ] && [ $RETRY -lt $CONNECTION_RETRY ]; do
	echo "CONSUL: Waiting for HOST IP is alive ..."
	sleep $RETRY_TIMEOUT_SECONDS
	let RETRY=RETRY+1
	export IP_ADDRESS="$(ifconfig $NETWORK_DEVICE|grep inet|awk 'BEGIN {FS=OFS=":"}{print $2}'|awk 'BEGIN {FS=OFS=" "}{print $1}')"
done
if [ "" = "$IP_ADDRESS" ]; then
	echo "CONSUL: Failed to obtain container host ip address ..."
	echo "CONSUL: Exit!!"
	exit 1
fi

echo "CONSUL: Node name: $NODE_NAME"
echo "CONSUL: IP Address: $IP_ADDRESS (Available in variable IP_ADDRESS)"

if [ "" = "$1" ]; then
	echo "CONSUL: Running the default agent ..."
	if [ "yes" != "$IS_CLUSTERED" ]; then
		echo "CONSUL: Running single instance ..."
		sh -c "consul agent -config-dir=/consul/config -bind=${IP_ADDRESS} -http-port ${HTTP_PORT} -dns-port ${DNS_PORT} -advertise=${IP_ADDRESS} -client=0.0.0.0"
	else
		echo "CONSUL: Running clustered instance ..."
	    BASE_COMMAND="consul agent -config-dir=/consul/config -node=$NODE_NAME -http-port ${HTTP_PORT} -dns-port ${DNS_PORT} -bind=${IP_ADDRESS} -advertise=${IP_ADDRESS} -client=0.0.0.0"
		if [ "" != "$COMMA_SEPARATED_NODES_LIST" ]; then
			IFS=",";for host in $COMMA_SEPARATED_NODES_LIST; do
				if [ "${IP_ADDRESS}" != "${host}" ] && [ "" = "$(echo "${host}"| grep "${NODE_NAME}")" ]; then
					if [ "yes" = "$NO_CHECK_NODES" ]; then
						echo "CONSUL: Adding cluster node: $host"
						BASE_COMMAND="$BASE_COMMAND -retry-join=$host"
					else
						QUALIFIED_NODE="$(qualifyNode "$host")"
						if [ "unreachable" = "${QUALIFIED_NODE,,}" ]; then
							echo "CONSUL: WARNING: Node $host is unreachable!!"
							echo "CONSUL: WARNING: Excluding for cluster join list"
						else
							echo "CONSUL: Adding cluster node: $host -> $QUALIFIED_NODE"
							BASE_COMMAND="$BASE_COMMAND -retry-join=$QUALIFIED_NODE"
						fi
					fi
				else
					echo "CONSUL: Skipping local host reference: $host"
				fi
			done
		fi
		echo "Executing command: $BASE_COMMAND"
		sh -c "$BASE_COMMAND"
	fi
else
	echo "CONSUL: Running command: $@"
	sh -c "$@"
fi
echo "CONSUL: Exit!!"
exit 0