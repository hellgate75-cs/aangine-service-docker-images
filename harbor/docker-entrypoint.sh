#!/bin/bash

function generateSSLCertificates() {
	touch /root/.rnd
	chmod 777 /root/.rnd
	DOMAIN_1="$DOMAIN_NAME"
	DOMAIN_2="$(echo $DOMAIN_NAME|awk 'BEGIN {FS=OFS="."}{print$1}')"
	if [ -e /root/certs ]; then
		rm -Rf /root/certs
	fi
	mkdir /root/certs
	echo "Creating CA root RSA private key ..."
	openssl genrsa -out /root/certs/ca.key 4096
	echo "Creating CA root certificate ..."
	openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "$CERTIFICATE_SUBJECT" \
 -key /root/certs/ca.key \
 -out /root/certs/ca.crt
 echo "Generate ${BUSINESS_NAME} Server RSA private key ..."
 openssl genrsa -out /root/certs/${BUSINESS_NAME}.key 4096
 echo "Generate ${BUSINESS_NAME} certificate request ..."
 openssl req -sha512 -new \
    -subj "$CERTIFICATE_SUBJECT" \
    -key /root/certs/${BUSINESS_NAME}.key \
    -out /root/certs/${BUSINESS_NAME}.csr
  echo "Copy and replacement of v2 parameters file ..."
  cp /root/v3.ext /root/certs/
  sed -i "s/DOMAIN_1/$DOMAIN_1/g" /root/certs/v3.ext
  sed -i "s/DOMAIN_2/$DOMAIN_2/g" /root/certs/v3.ext
  sed -i "s/HOSTNAME/$(hostname)/g" /root/certs/v3.ext
  echo "v3 parameters file (/root/certs/v3.ext) :"
  cat /root/certs/v3.ext
  echo "Generate ${BUSINESS_NAME} Server certificate ..."
  openssl x509 -req -sha512 -days 3650 \
    -extfile /root/certs/v3.ext \
    -CA /root/certs/ca.crt -CAkey /root/certs/ca.key -CAcreateserial \
    -in /root/certs/${BUSINESS_NAME}.csr \
    -out /root/certs/${BUSINESS_NAME}.crt
  echo "Generate ${BUSINESS_NAME} docker complaint certificate with 'cert' extension ..."
  openssl x509 -inform PEM -in /root/certs/${BUSINESS_NAME}.crt -out /root/certs/${BUSINESS_NAME}.cert
}
if [ -e /root/harbor ]; then
	cd /root
	mkdir /data
	echo "HARBOR: Installing harbor on first container start ..."
	echo "HARBOR: You must have shared /var/run/docker.sock pipe from"
	echo "        host machine"
	echo "HARBOR: Generating keys and certificates ..."
	generateSSLCertificates
	if [ -e /data/cert ]; then
		rm -Rf /data/cert
	fi
	mkdir -p /data/certs
	echo "HARBOR: Copying certificates ..."
	cp /root/certs/ca.crt /data/certs/ca.crt
	cp /root/certs/${BUSINESS_NAME}.crt /data/certs/certificate.crt
	cp /root/certs/${BUSINESS_NAME}.key /data/certs/private.key
	echo "HARBOR: Generating/Copying docker certificates ..."
	mkdir -p /etc/docker/certs.d/${BUSINESS_NAME}/
	cp /root/certs/${BUSINESS_NAME}.cert /etc/docker/certs.d/${BUSINESS_NAME}/
	cp /root/certs/${BUSINESS_NAME}.key /etc/docker/certs.d/${BUSINESS_NAME}/
	cp /root/certs/ca.crt /etc/docker/certs.d/${BUSINESS_NAME}/
	mkdir -p /var/log/harbor
	if [ "" != "$HARBOR_YAML_FILE_URL" ]; then
		echo "HARBOR: Downloading custom HArbor configuration: $HARBOR_YAML_FILE_URL ..."
		wget -sL $HARBOR_YAML_FILE_URL -o /root/harbor/harbor.yml
	fi
	echo "HARBOR: Installing Harbor binaries/docker containers ..."
	bash /root/harbor/install.sh
	RET="$?"
	if [ "x0" = "x$RET" ]; then
		echo "HARBOR: Installation succeded!!"
		#echo "HARBOR: Removing installation folder (/root/harbor) ..."
		#rm -Rf /root/harbor
	else
		echo "HARBOR: Installation failed!!"
		echo "HARBOR: Exit code: $RET"
	fi
fi
cd /
if [ "x" != "x$@" ]; then
	echo "HARBOR: Executing command : $@ ..."
	sh -c "$@"
fi
sleep 10
echo "HARBOR: Printing logs ..."
#ls -latr /var/log/harbor/
#tail -f /var/log/harbor/harbor.log
tail -f /root/install-harbor.sh
echo "HARBOR: Continer exit!!"
exit 0