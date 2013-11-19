#!/bin/bash -vex

# needed rpms
#yum -y install ncurses-devel git gcc rpmbuild

KERNEL_VERSION=3.10.19
test -f linux-${KERNEL_VERSION}.tar.xz || \
  wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL_VERSION}.tar.xz

# get aufs user tools and build tar
printf "build aufs3-standalone\n"
rm -rf aufs3-standalone
git clone git://git.code.sf.net/p/aufs/aufs3-standalone

cd aufs3-standalone
git checkout aufs3.10
git archive aufs3.10 --prefix='aufs3-standalone-3.10/' --format=tar | gzip -9 > ../aufs3-standalone-3.10.tar.gz
cd ..
rm -rf aufs3-standalone

rpmbuild -bs --nodeps --define "_sourcedir ." --define "_srcrpmdir ." kernel-docker.spec

# either mock or rpmbuild

build_dir="$(mktemp -d)"
mkdir -p $build_dir/{SOURCES,RPMS,SRPMS,BUILD,SPECS}

srcrpm=`ls -1 kernel-*.src.rpm`
rpmbuild --rebuild --define "_topdir ${build_dir}" $srcrpm

mv $build_dir/RPMS/*.rpm .
