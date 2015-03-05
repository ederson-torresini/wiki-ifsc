# Modificado (arquivo todo)

FROM debian:testing
MAINTAINER Ederson Torresini <boidacarapreta@gmail.com>

RUN	apt-get update && \
	apt-get install -y bash && \
	apt-get install -y varnish && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

CMD ["varnishd","-F","-a",":80","-f","/etc/varnish/default.vcl"]
