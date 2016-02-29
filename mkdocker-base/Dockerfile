FROM debian:jessie
MAINTAINER GP Orcullo <kinsamanka@gmail.com>

ENV TERM dumb
ENV ROOTFS /opt/rootfs

# apt config:  silence warnings and set defaults
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
ENV LC_ALL C 
ENV LANGUAGE C
ENV LANG C

# disable security updates due to frequent Hash Sum Mismatch
RUN sed -i '/security/d' /etc/apt/sources.list

# turn off recommends on container OS and proot OS
RUN echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
            /etc/apt/apt.conf.d/01norecommend && \
    mkdir -p ${ROOTFS}/etc/apt/apt.conf.d && \
    echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
            ${ROOTFS}/etc/apt/apt.conf.d/01norecommend

# install native cross-compiler
ADD http://emdebian.org/tools/debian/emdebian-toolchain-archive.key /tmp/
RUN apt-key add /tmp/emdebian-toolchain-archive.key && \
    echo "deb http://emdebian.org/tools/debian/ jessie main" >> \
        /etc/apt/sources.list.d/emdebian.list && \
    dpkg --add-architecture armhf
    
# install required dependencies
RUN apt-get update && \
    apt-get -y install \
        bzip2 \
        crossbuild-essential-armhf \
        multistrap \
        git \
        proot \
        qemu-user-static

ADD proot-helper /bin/
