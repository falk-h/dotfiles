FROM archlinux:latest

RUN pacman -Syu --noconfirm bash openssh git vim ncurses \
 && pacman -Scc --noconfirm

COPY utils.sh init.sh /

CMD ["/init.sh"]
