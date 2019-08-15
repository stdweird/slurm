#!/bin/bash

VERSION=`grep "Version:.*[0-9]" slurm.spec | tr -s " " |  awk '{print $2;}'`
RELEASE=`grep "%global rel.*[-1-9]" slurm.spec | tr -s " " | awk '{print $3}'`

if [ ${RELEASE} != "1" ]; then
    SUFFIX=${VERSION}-${RELEASE}
else
    SUFFIX=${VERSION}
fi

GITTAG=$(git log --format=%ct.%h -1)

mkdir -p BUILD SOURCES SPECS RPMS BUILDROOT
git archive --format=tar.gz -o "SOURCES/slurm-${SUFFIX}.tar.gz" --prefix="slurm-${SUFFIX}/" HEAD
cp slurm.spec "SPECS"

sudo yum install -y nvidia-driver-NVML ucx-devel pmix-devel numactl-devel hwloc-devel
# there's no option to pass nvml, it is only autodetected
rpmbuild --define "gittag ${GITTAG}" --define "_topdir $PWD" --with numa --with pmix --with hwloc --with x11 --with ucx -ba SPECS/slurm.spec
