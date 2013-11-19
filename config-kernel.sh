#!/bin/sh -vex

KERNEL_VERSION=3.10.19

TEMPDIR="$(mktemp -d --suffix=build-kernel)"
HERE="$(pwd)"

printf "configuring at: %s\n" $TERMDIR
cd $TEMPDIR
# get the linux kernels
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL_VERSION}.tar.xz

tar -xJvf linux-${KERNEL_VERSION}.tar.xz

# get aufs sources
git clone git://git.code.sf.net/p/aufs/aufs3-standalone

cd aufs3-standalone
git checkout origin/aufs3.10

cd ..

patch -d linux-${KERNEL_VERSION} -p1 < aufs3-standalone/aufs3-kbuild.patch
patch -d linux-${KERNEL_VERSION} -p1 < aufs3-standalone/aufs3-base.patch
patch -d linux-${KERNEL_VERSION} -p1 < aufs3-standalone/aufs3-mmap.patch
patch -d linux-${KERNEL_VERSION} -p1 < aufs3-standalone/aufs3-standalone.patch

rm -rf aufs3-standalone/include/uapi/linux/Kbuild
cp -r aufs3-standalone/{Documentation,fs,include} linux-${KERNEL_VERSION}

cd linux-${KERNEL_VERSION}
make mrproper
cp $HERE/config-docker-${KERNEL_VERSION} .config

make menuconfig
cp .config $HERE/kernel-config-$(date +"%m-%d-%y-%H-%M")

cd $HERE
