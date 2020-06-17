FROM consul:latest

ENV IS_CLUSTERED=no\
 DOMAIN=aangine\
 NO_CHECK_NODES=no\
 COMMA_SEPARATED_NODES_LIST=\
 USE_CUSTOM_CONFIG=no\
 CONNECTION_RETRY=10\
 RETRY_TIMEOUT_SECONDS=20\
 NETWORK_DEVICE=eth0\
 HTTP_PORT=8500\
 DNS_PORT=8600
 
RUN mkdir -p /consul/templates/single &&\
 mkdir -p /consul/templates/cluster &&\
 mkdir -p /consul/config &&\
 mkdir -p /consul/data &&\
 chmod -Rf 0660 /consul
 
COPY config/single/* /consul/templates/single/
COPY config/cluster/* /consul/templates/cluster/
COPY docker-entrypoint.sh /

RUN dos2unix /consul/templates/single/* &&\
 dos2unix /consul/templates/cluster/* &&\
 dos2unix /docker-entrypoint.sh &&\
 chmod +x /docker-entrypoint.sh

VOLUME ["/consul/config", "/consul/data", "/consul/templates"]

EXPOSE 8500/tcp 8600/udp

ENTRYPOINT ["/docker-entrypoint.sh"]