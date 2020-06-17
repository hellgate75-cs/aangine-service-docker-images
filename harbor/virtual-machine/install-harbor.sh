#!/bin/bash
cd /root
mkdir -p /hostfs
ln -s /data /hostfs/data
URL="$(curl -sL -X GET -o - https://github.com/goharbor/harbor/releases|grep a|grep harbor|grep download|grep -v downloads|grep -v md5|awk 'BEGIN {FS=OFS="href=\""}{print $2}'|awk 'BEGIN {FS=OFS="\""}{print $1}'|grep -v asc|grep offline|head -1)"
if [ "" != "$URL" ]; then
	echo "Downloading Harbor from url: https://github.com${URL}"
	curl -sL -X GET https://github.com${URL} -o /root/harbor-offline-installer.tgz
	gpg --keyserver hkps://keyserver.ubuntu.com --receive-keys 644FF454C0B4115C
	tar xvf /root/harbor-offline-installer.tgz -C /root/
	rm -f /root/harbor-offline-installer.tgz
else
	echo "Canot download harbor offline installer archive: url not available"
	echo "Abort!"
	exit 1
fi
exit 0