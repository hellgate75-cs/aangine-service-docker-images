#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"
if [ -e /root/platform ]; then
	cd /root/platform
	docker-compose -f $FOLDER/docker-compose.yml stop 1>&2 /dev/null
	docker-compose -f $FOLDER/docker-compose.yml down --rmi all --remove-orphans --volumes 1>&2 /dev/null
fi
if [ -e /root/harbor ]; then
	cd /root/harbor
	docker-compose -f ./docker-compose.yml stop 1>&2 /dev/null
	docker-compose -f ./docker-compose.yml down --rmi all --remove-orphans --volumes 1>&2 /dev/null
fi
bash $FOLDER/clean-all-docker-containers.sh
bash $FOLDER/clean-all-docker-images.sh
sudo update-rc.d harbor defaults-disabled
sudo update-rc.d harbor disable
sudo update-rc.d harbor remove
rm -Rf /data /input /root/harbor /root/certs /var/log/harbor /root/.gnupg /hostfs /root/config /opt/harbor/data /opt/clair/data /opt/notary/signer/data /opt/notary/server/data /root/platform
rm -f /root/*.sh /root/*.yml /start-harbor.sh /root/v3.txt /root/.rnd /etc/init.d/harbor
