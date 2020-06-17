FROM ubuntu:bionic

ENV ZONE_NAME="aangine"\
 FORWARDERS="8.8.8.8;8.8.4.4"\
 DEBIAN_FRONTEND=noninteractive\
 USE_CONFIG_FROM_VOLUME=no\
 REBUILD_CONFIG=once

RUN apt-get update \
  && apt-get install -y apt-utils \
  tar \
  lzma \
  gzip \
  && apt-get install -y \
  curl \
  vim \
  dos2unix \
  net-tools \
  iproute2 \
  bind9 \
  bind9utils \
  bind9-doc &&\
 apt-get autoremove &&\
 rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY named.conf.options /etc/bind/
COPY named.conf.local /etc/bind/
COPY named.conf.log /etc/bind/
COPY logrotate-bind /etc/logrotate.d/bind
COPY db.my-site.com /etc/bind/zones/

# Copy entry point
COPY docker-entrypoint.sh /

# Enable IPv4
RUN sed -i 's/OPTIONS=.*/OPTIONS="-4 -u bind"/' /etc/default/bind9 &&\
 dos2unix /docker-entrypoint.sh &&\
 dos2unix /etc/logrotate.d/bind &&\
 dos2unix /etc/bind/* &&\
 dos2unix /etc/bind/zones/* &&\
 mkdir /var/log/bind &&\
 chown bind:bind /var/log/bind &&\
 echo "include \"/etc/bind/named.conf.log\";" >> /etc/bind/named.conf &&\
 update-rc.d bind9 defaults &&\
 update-rc.d bind9 enable &&\
 chmod +x /docker-entrypoint.sh

VOLUME ["/etc/bind"]

EXPOSE 53/tcp 53/udp

#Entry point

ENTRYPOINT ["/docker-entrypoint.sh"]