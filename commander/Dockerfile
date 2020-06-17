FROM ubuntu:bionic

COPY docker-entrypoint.sh /

RUN apt-get update \
  && apt-get install -y apt-utils \
  tar \
  wget \
  curl \
  vim \
  dos2unix \
  net-tools \
  dnsutils \
  iproute2 \
  gnupg\
  openssl &&\
 apt-get upgrade -y &&\
 apt-get autoremove -y &&\
 rm -rf /var/lib/apt/lists/*&&\
 mkdir -p /mnt/sda &&\
 dos2unix /docker-entrypoint.sh &&\
 chmod 777 /docker-entrypoint.sh

VOLUME ["/mnt/sda"]

ENTRYPOINT ["/docker-entrypoint.sh"]