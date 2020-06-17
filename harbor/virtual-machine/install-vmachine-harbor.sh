#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"
if [ "" = "$(which docker 2>/dev/null)" ]; then
	echo "Installing pre-requisites ..."
	bash $FOLDER/install-prereq.sh
fi
echo "Running folder: $FOLDER"
bash ./uninstall-vmachine-harbor.sh
export CERTIFICATE_SUBJECT="/C=CN/ST=Dublin/L=Dublin/O=Optiim/OU=ICT/CN=optiim.com"
export BUSINESS_NAME="optiim.com"
export DOMAIN_NAME="optiim.com"
export HARBOR_YAML_FILE_URL=
export HOSTNAME="$(hostname)"

# platform services folders
mkdir -p /root/config
mkdir -p /opt/harbor/data
mkdir -p /opt/clair/data
mkdir -p /opt/notary/signer/data
mkdir -p /opt/notary/server/data

cp clair-config.yml /root/config
dos2unix /root/config/*
sed -i "s/HOSTNAME/$(hostname)/g" /root/config/clair-config.yml
mkdir -p /root/platform/bin
cp ./docker-compose.yml /root/platform/
cp start-harbor.sh /root/platform/bin/
cp stop-harbor.sh /root/platform/bin/
cp status-harbor.sh /root/platform/bin/
cp setup-harbor.sh /root/platform/bin/
cp uninstall-vmachine-harbor.sh /root/platform/bin/uninstall-harbor.sh
cp clean-all-docker-containers.sh /root/platform/bin/
cp clean-all-docker-images.sh /root/platform/bin/
cd /root/platform
docker-compose -f ./docker-compose.yml up -d --no-recreate --remove-orphans --no-deps
cd $FOLDER

cp install-harbor.sh /root/
cp v3.txt /root/v3.txt

mkdir -p /root/harbor
mkdir /input
mkdir -p /var/log/harbor

cp harbor.yml /root/harbor/
cp harbor.yml /input/

mv /root/v3.txt /root/v3.ext
dos2unix /root/platform/*
dos2unix /root/platform/bin/*
dos2unix /root/*
dos2unix /input/*
dos2unix /root/harbor/*
chmod 777 /root/*.sh
chmod 777 /root/platform/bin/*
bash /root/install-harbor.sh
cp harbor /etc/init.d/
cp default /etc/default/harbor
dos2unix /etc/init.d/harbor
dos2unix /etc/default/harbor
chmod +x /etc/init.d/harbor
sudo update-rc.d harbor defaults
sudo update-rc.d harbor enable
/root/platform/bin/setup-harbor.sh
/etc/init.d/harbor start
