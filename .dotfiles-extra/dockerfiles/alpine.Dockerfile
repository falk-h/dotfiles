FROM alpine:latest

RUN apk upgrade --no-cache \
 && apk add --no-cache bash openssh git vim ncurses

COPY utils.sh init.sh /

CMD ["/init.sh"]
