FROM ubuntu:bionic

ENV CERTIFICATE_SUBJECT="/C=CN/ST=Dublin/L=Dublin/O=Optiim/OU=ICT/CN=optiim.com"\
	BUSINESS_NAME="optiim.com"\
	DOMAIN_NAME="optiim.com"\
	HARBOR_YAML_FILE_URL=\
	HOSTNAME=

RUN apt-get update \
  && apt-get install -y apt-utils \
  tar \
  wget \
  curl \
  vim \
  dos2unix \
  net-tools \
  iproute2 \
  gnupg\
  openssl \
  docker.io &&\
 apt-get upgrade -y &&\
 apt-get autoremove &&\
 rm -rf /var/lib/apt/lists/*

COPY install-harbor.sh /root
COPY docker-entrypoint.sh /
COPY docker-install-pkgs /bin
COPY v3.txt /root

RUN mkdir -p /root/harbor &&\
    mkdir /input

COPY harbor.yml /root/harbor
COPY harbor.yml /input

RUN mv /root/v3.txt /root/v3.ext &&\
  mv /bin/docker-install-pkgs /bin/install-pkgs &&\
  dos2unix /bin/install-pkgs &&\
  chmod 777 /bin/install-pkgs &&\
  VERSION="$( curl -s -o - https://github.com/docker/compose/releases|grep "<a"|grep \/docker\/compose\/releases\/download\/|grep Linux|awk 'BEGIN {FS=OFS="href=\""}{print $2}'|awk 'BEGIN {FS=OFS="\""}{print $1}'|awk 'BEGIN {FS=OFS="/"}{print $6}'|head -1)" &&\
  curl -L "https://github.com/docker/compose/releases/download/$VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose &&\
  chmod 777 /usr/bin/docker-compose &&\
  dos2unix /root/* &&\
  dos2unix /input/* &&\
  dos2unix /root/harbor/* &&\
  chmod 777 /root/install-harbor.sh &&\
  dos2unix /docker-entrypoint.sh &&\
  chmod 777 /docker-entrypoint.sh &&\
  sh /root/install-harbor.sh

VOLUME ["/var/run/docker.sock", "/data", "/root", "/input"]

ENTRYPOINT ["/docker-entrypoint.sh"]
