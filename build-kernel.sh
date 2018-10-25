#!/bin/bash

mkdir -p output/

docker run -ti \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -e "DEBEMAIL=Ashley TheFoxie <pine@victorianfox.com>" \
  -e "KDEB_CHANGELOG_DIST=stable" \
  -u `id -u`:`id -g` \
  -v `pwd`/:/base \
     aarch64-builder \
       /bin/bash -e -c '\
  echo "===== Building Kernel =====" && \
  cd /base/components/linux/ && \
  git clean -f -x -d && \
  git reset HEAD --hard && \
  (for i in `ls /base/patches/kernel/*`; do \
    patch -p1 < $i; \
  done) && \
  cp /base/config/kernel.config .config && \
  ARCH=arm64 make clean && \
  ARCH=arm64 make oldconfig && \
  ARCH=arm64 make -j5 deb-pkg KBUILD_IMAGE=arch/arm64/boot/Image && \
  mv ../*.deb /base/output/ && \
  rm ../*.changes && \
  echo "===== Building Meta Package ====" && \
  KERNELVERSION=`cd /base/components/linux && make kernelversion` && \
  cd /base/linux-image-pine64/ && \
  ./update.sh $KERNELVERSION && \
  mv /base/linux-image-pine64*.deb /base/output/ && \
  rm /base/linux-image-pine64*.changes /base/linux-image-pine64*.buildinfo'
