FROM debian:testing
MAINTAINER Ederson Torresini <boidacarapreta@gmail.com>

RUN	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install haproxy && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

CMD ["haproxy","-f","/etc/haproxy/haproxy.cfg"]
