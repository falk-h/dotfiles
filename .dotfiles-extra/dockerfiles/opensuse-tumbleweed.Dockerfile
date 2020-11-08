FROM opensuse/tumbleweed:latest

RUN zypper update --no-confirm \
 && zypper install --no-confirm bash openssh-clients git vim ncurses-utils \
 && zypper clean --all

COPY utils.sh init.sh /

CMD ["/init.sh"]
