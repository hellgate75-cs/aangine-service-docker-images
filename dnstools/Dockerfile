FROM ubuntu:bionic

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y apt-utils \
  tar \
  lzma \
  gzip \
  curl \
  vim \
  dos2unix \
  net-tools \
  iproute2 \
  dnsutils &&\
 apt-get autoremove &&\
 rm -rf /var/lib/apt/lists/*


# Copy entry point
COPY docker-entrypoint.sh /

# Enable IPv4
RUN dos2unix /docker-entrypoint.sh &&\
 chmod +x /docker-entrypoint.sh


#Entry point

ENTRYPOINT ["/docker-entrypoint.sh"]