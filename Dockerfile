FROM kinsamanka/mkdocker:base
MAINTAINER GP Orcullo <kinsamanka@gmail.com>
#
# These variables configure the build.
#
ENV SUITE [suite]
ENV ARCH  [arch]
#
# [Leave surrounding comments to eliminate merge conflicts]
#

# build under ${ROOTFS}
RUN mkdir -p ${ROOTFS} && \
    debootstrap --foreign --no-check-gpg --include=ca-certificates \
        --arch=${ARCH} ${SUITE} ${ROOTFS} http://httpredir.debian.org/debian
RUN proot-helper /debootstrap/debootstrap --second-stage --verbose

# configure apt
# official Debian repos
RUN sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE} main" \
        > ${ROOTFS}/etc/apt/sources.list' && \
    sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-updates \
        main" >> ${ROOTFS}/etc/apt/sources.list' && \
    sh -c 'echo "deb http://security.debian.org ${SUITE}/updates main" \
        >> ${ROOTFS}/etc/apt/sources.list' && \
    sh -c 'echo "deb http://httpredir.debian.org/debian ${SUITE}-backports \
        main" >> ${ROOTFS}/etc/apt/sources.list'
# 3rd-party MK deps repo
RUN proot-helper apt-key adv --keyserver hkp://keys.gnupg.net \
        --recv-key 73571BB9 && \
    echo "deb http://builder2.zultron.com ${SUITE} main" \
         > ${ROOTFS}/etc/apt/sources.list.d/machinekit.list
# update apt db
RUN proot-helper apt-get update 

# install debian development dependencies
RUN proot-helper apt-get install -y \
        devscripts \
        equivs \
        fakeroot \
        git \
        less \
        lsb-release \
        python-debian

# install MK dependencies
ADD mk_depends ${ROOTFS}/tmp/
# mk_depends lists deps independent of $SUITE and $ARCH
RUN proot-helper xargs -a /tmp/mk_depends apt-get install -y
RUN rm ${ROOTFS}/tmp/mk_depends

# cython package is in backports on Wheezy
RUN test $SUITE = wheezy \
        && proot-helper apt-get install -y -t wheezy-backports cython \
        || proot-helper apt-get install -y cython

# tcl/tk latest is v. 8.5 in Wheezy
RUN test $SUITE = wheezy \
        && proot-helper apt-get install -y tcl8.5-dev tk8.5-dev \
        || proot-helper apt-get install -y tcl8.6-dev tk8.6-dev

# use gcc-4.7 for wheezy
RUN test $SUITE = wheezy && proot-helper apt-get install -y gcc-4.7

# cleanup apt
RUN proot-helper apt-get clean

# copy arm-linux-gnueabihf-* last to clobber package installs
ADD bin/* ${ROOTFS}/usr/bin/

# fix resolv.conf
RUN echo "nameserver 8.8.8.8\nnameserver 8.8.4.4" \
        > ${ROOTFS}/etc/resolv.conf
