FROM ubuntu

RUN apt-get update
RUN bash -c " \
  apt-get install -y git cmake ninja-build clang python uuid-dev libicu-dev \
    icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig \
    libssl-dev libpython-dev libncurses5-dev pkg-config wget curl nano \
    mysql-server mysql-client libmysqlclient-dev nginx \
    ; \
  apt-get install -y clang-3.6 ; \
  update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100; \
  update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100; \
"

RUN mkdir -p /var/swift/swift-dev
WORKDIR /var/swift/swift-dev
RUN echo " \
#! /bin/bash \n\
if [ ! -d "/var/swift/swift-dev/swift" ]; then \n\
  git clone https://github.com/apple/swift.git /var/swift/swift-dev/swift; \n\
fi \n\
cd /var/swift/swift-dev/swift; \n\
./utils/update-checkout --clone; \n\
" >> /checkout_swift.bash
RUN chmod +x /checkout_swift.bash

RUN echo " \
#! /bin/bash \n\
mkdir -p /var/swift/swift-bin/linux-built; \n\
cd /var/swift/swift-dev/swift; \n\
./utils/build-script --preset=mixin_linux_installation install_destdir=/var/swift/swift-bin/linux-built installable_package=/var/swift/swift-bin/linux-built.tar.gz; \n\
" >> /build_swift.bash
RUN chmod +x /build_swift.bash

ARG swift_version=swift-DEVELOPMENT-SNAPSHOT-2016-01-25-a
ARG ubuntu_version=ubuntu1404
ARG ubuntu_version_path=ubuntu14.04

ENV swift_filename $swift_version-$ubuntu_version_path
ENV swift_path https://swift.org/builds/development/$ubuntu_version/$swift_version/$swift_filename.tar.gz

RUN echo  " \
mkdir -p /var/swift/swift-bin/linux-snapshot; \n\
cd /var/swift/swift-bin/linux-snapshot; \n\
swift_path=\"$swift_path\"\n\
swift_filename=\"$swift_filename\"\n\
wget \$swift_path; \n\
tar xzf \$swift_filename.tar.gz; \n\
mv \$swift_filename/usr usr; \n\
rm -r \$swift_filename; \n\
rm \$swift_filename.*; \n\
" >> /download_swift.bash
RUN chmod +x /download_swift.bash

ENV PATH /var/swift/swift-bin/linux-built/usr/bin:/var/swift/swift-bin/linux-snapshot/usr/bin:$PATH

ENV swift_filename ""
ENV swift_path ""

WORKDIR /var/swift
VOLUME /var/swift

EXPOSE 8080
EXPOSE 80

CMD /bin/bash -l