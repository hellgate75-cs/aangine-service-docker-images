#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"

function usage() {
	echo "docker-entrypoint.sh {cmd} {arg1} ... {argN}"
	echo "  {cmd}    				command you want run"
	echo "  {arg1} ... {argN}		Command Arguments arg1 ... argN"
}

if [ "-h" = "$1" ] || [ "--help" = "$1" ]; then
	echo "Usage:"
	echo -e "$(usage)"
	echo "DNSTOOLS: Exit!!"
	exit 0
fi

echo "DNSTOOLS: Starting DnsTools Container ..."



if [ $# -gt 0 ]; then
	echo "DNSTOOLS: Running command: $@"
	eval "$@"
fi 
sleep infinity
echo "DNSTOOLS: Exit!!"
exit 0