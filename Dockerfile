FROM centos:7
MAINTAINER marco.bulgarini@gmail.com

ENV version=${version:-chaos_calmer}
ENV release=${release:-15.05}
ENV architecture=${architecture:-ar71xx}
ENV type=${type:-generic}

# Build container with base tools
RUN yum update -y
RUN yum check-update && yum install -y wget \
 bzip2 \
 deltarpm \
 && yum clean all
# Add build deps to container
RUN yum check-update && yum install -y subversion \
 make \
 automake \
 gcc \
 gcc-c++ \
 kernel-devel \
 ncurses-devel \
 zlib-devel \
 git \
 gawk \
 gettext \
 openssl \
 && yum clean all

RUN useradd -m openwrt-imagegenerator
USER openwrt-imagegenerator
WORKDIR /home/openwrt-imagegenerator

RUN wget  https://downloads.openwrt.org/${version}/${release}/${architecture}/${type}/OpenWrt-ImageBuilder-${release}-${architecture}-${type}.Linux-x86_64.tar.bz2 \
 && tar -xvjf OpenWrt-ImageBuilder-${release}-${architecture}-${type}.Linux-x86_64.tar.bz2
RUN mv /home/openwrt-imagegenerator/OpenWrt-ImageBuilder-${release}-${architecture}-${type}.Linux-x86_64 /home/openwrt-imagegenerator/buildenv \
 && rm -f OpenWrt-ImageBuilder-${release}-${architecture}-${type}.Linux-x86_64.tar.bz2
WORKDIR /home/openwrt-imagegenerator/buildenv
ENV PATH /home/openwrt-imagegenerator/buildenv:$PATH

RUN mkdir -p /home/openwrt-imagegenerator/buildenv/files-to-include/etc/config
VOLUME ["/home/openwrt-imagegenerator/buildenv/files-to-include","/home/openwrt-imagegenerator/buildenv/bin"]
ENTRYPOINT ["make"]
CMD ["help"]
# image will be in bin/ar71xx/
RUN make clean
