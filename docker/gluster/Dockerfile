FROM debian:stable
MAINTAINER Ederson Torresini <boidacarapreta@gmail.com>

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb http://httpredir.debian.org/debian/ stable main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ stable/updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install glusterfs-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 24007
EXPOSE 24008
EXPOSE 49152
CMD ["/usr/sbin/glusterd", "-N"]
