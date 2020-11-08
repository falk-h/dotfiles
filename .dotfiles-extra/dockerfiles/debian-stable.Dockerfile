FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get upgrade --assume-yes \
 && apt-get install --assume-yes bash ssh git vim ncurses-bin \
 && rm -rf /var/lib/apt/lists/*

COPY utils.sh init.sh /

CMD ["/init.sh"]
