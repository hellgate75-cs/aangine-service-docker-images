#!/bin/sh
sudo chmod 777 ./install-pkgs
sudo chown root:root ./install-pkgs
sudo mv ./install-pkgs /bin/
sudo install-pkgs tar wget curl vim dos2unix net-tools openssl iproute2 gnupg docker.io ca-certificates jq
VERSION="$( curl -s -o - https://github.com/docker/compose/releases|grep "<a"|grep \/docker\/compose\/releases\/download\/|grep Linux|awk 'BEGIN {FS=OFS="href=\""}{print $2}'|awk 'BEGIN {FS=OFS="\""}{print $1}'|awk 'BEGIN {FS=OFS="/"}{print $6}'|head -1)"
sudo   curl -sL --fail "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
/usr/bin/docker-compose version