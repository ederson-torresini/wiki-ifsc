# Modificado (arquivo todo)

FROM debian:testing
MAINTAINER Ederson Torresini <boidacarapreta@gmail.com>

RUN	apt-get update && \
	apt-get install -y bash && \
	apt-get install -y php5-fpm && \
	apt-get install -y php5-memcached && \
	apt-get install -y php5-apc && \
	apt-get install -y php5-mysql && \
	apt-get install -y php5-intl && \
	apt-get install -y php5-gd && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

CMD ["php5-fpm","-F"]
