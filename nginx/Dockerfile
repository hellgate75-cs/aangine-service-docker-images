FROM registry.gitlab.com/continuous-software/platform-service-nginx/development:latest

ENV DEBIAN_FRONTEND=noninteractive\
 CONSUL_URL=consul-public:8500\
 GUI_SERVICE=aangine-ui:80\
 GUI_SERVICE_NEEDED=false\
 AUTH_SERVICE_NAME=auth-service\
 USE_SSL=false\
 IS_NGINX_NO_AUTH=false\
 NGINX_SSL_CERT_PATH=/etc/nginx/certs/certificate.crt\
 NGINX_SSL_KEY_PATH=/etc/nginx/certs/private.key\
 NGINX_SSL_SERVER_NAME=aangine\
 NGINX_SSL_DOMAIN_NAME=aangine.continuous.software\
 CERTIFICATES_TAR_GZ_URL=\
 SERVICE_PORT=80

RUN apt-get update \
 && apt-get install -y apt-utils \
 && apt-get install -y tar \
 curl \
 vim \
 dos2unix \
 net-tools \
 iproute2 \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/shared/ngnix-templates/get &&\
 mkdir -p /usr/shared/ngnix-templates/set &&\
 mkdir -p /usr/shared/ngnix-certs &&\
 mkdir -p /var/www/static/

COPY config/templates/api-doc.html /usr/shared/ngnix-templates/
COPY config/templates/service-no-auth.ctmpl /usr/shared/ngnix-templates/
COPY config/templates/service-single-port.ctmpl /usr/shared/ngnix-templates/
COPY config/templates/service-single-port-no-ui.ctmpl /usr/shared/ngnix-templates/
COPY config/templates/get/.htpasswd /usr/shared/ngnix-templates/get/
COPY config/templates/set/.htpasswd /usr/shared/ngnix-templates/set/
COPY config/aangine-certs/ca_bundle.crt /usr/shared/ngnix-certs/
COPY config/aangine-certs/certificate.crt /usr/shared/ngnix-certs/
COPY config/aangine-certs/private.key /usr/shared/ngnix-certs/

COPY docker-entrypoint.sh /

RUN dos2unix /usr/shared/ngnix-templates/* &&\
 dos2unix /docker-entrypoint.sh &&\
 chmod +x /docker-entrypoint.sh
 
VOLUME ["/templates", "/etc/nginx/certs", "/usr/shared/ngnix-templates", "/usr/shared/ngnix-certs"]

EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
