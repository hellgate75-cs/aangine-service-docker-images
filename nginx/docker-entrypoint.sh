#!/bin/bash
FOLDER="$(realpath "$(dirname "$0")")"
COMMAND=""
if [ $# -gt 0 ]; then
	COMMAND="$@"
fi

function usage() {
	echo "docker-entrypoint.sh {cmd} {arg1} ... {argN}"
	echo "  {cmd}    				command you want run"
	echo "  {arg1} ... {argN}		Command Arguments arg1 ... argN"
}

if [ "-h" = "$1" ] || [ "--help" = "$1" ]; then
	echo "Usage:"
	echo "$(usage)"
	echo "NGINX: Exit!!"
	exit 0
fi

if [ ! -e ~/.started ]; then
	#echo "NGINX: Template folder content:"
	#ls -latr /usr/shared/ngnix-templates/
	dos2unix /usr/shared/ngnix-templates/*
	if [ "true" = "$IS_NGINX_NO_AUTH" ]; then
		echo "NGINX: No auth template selection ..."
		cat /usr/shared/ngnix-templates/service-no-auth.ctmpl > /templates/service.ctmpl
	else
		if [ "true" = "$GUI_SERVICE_NEEDED" ]; then
			# with gui
			echo "NGINX: GUI template selection ..."
			cat /usr/shared/ngnix-templates/service-single-port.ctmpl > /templates/service.ctmpl
		else
			# without gui
			echo "NGINX: NO GUI template selection ..."
			cat /usr/shared/ngnix-templates/service-single-port-no-ui.ctmpl > /templates/service.ctmpl
		fi
	fi
	chmod 666 /templates/service.ctmpl
	sed -i "s/LISTEN_PORT/$SERVICE_PORT/g" /templates/service.ctmpl
	cp -f /usr/shared/ngnix-templates/api-doc.html /templates/
	cp -Rf /usr/shared/ngnix-templates/get /var/www/static/
	cp -Rf /usr/shared/ngnix-templates/set /var/www/static/
	if [ "true" = "$USE_SSL" ]; then
		#ssl enabled
		if [ "" != "$CERTIFICATES_TAR_GZ_URL" ]; then
			curl -sL -o ~/certificates.tgz $CERTIFICATES_TAR_GZ_URL
			if [ -e ~/certificates.tgz ]; then
				rm -f /usr/shared/ngnix-certs/*
				tar -xzf ~/certificates.tgz -C /usr/shared/ngnix-certs/
			else
				echo "NGINX: Could not download certificates from url: $CERTIFICATES_TAR_GZ_URL"
				echo "NGINX: Using default ones..."
			fi
			
		fi		
		#echo "NGINX: Certificates folder content:"
		#ls -latr /usr/shared/ngnix-certs/
		cp /usr/shared/ngnix-certs/certificate.crt /etc/nginx/certs/
		cp /usr/shared/ngnix-certs/private.key /etc/nginx/certs/
		cp /usr/shared/ngnix-certs/ca_bundle.crt /usr/local/share/ca-certificates/continuous-software.crt
		update-ca-certificates
	fi
	touch ~/.started
fi

if [ "" != "$COMMAND" ]; then
	echo "NGINX: Running command: $COMMAND"
	eval "$COMMAND"
fi
bash /bin/start.sh
echo "NGINX: Exit!!"
exit 0