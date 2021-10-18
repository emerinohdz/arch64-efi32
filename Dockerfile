FROM docker.io/archlinux:base-20211010.0.36274

RUN pacman -Sy \
    && pacman -S --noconfirm wget make grub archboot-grub cdrtools libisoburn dosfstools mtools \
    && pacman -Scc --noconfirm

ARG UID
ARG GID
RUN groupadd dev -g "$GID" && useradd -l -u "$UID" -g "$GID" dev

USER dev