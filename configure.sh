#!/bin/bash


ARCH="-march=armv8.3-a+crypto"
# ARCH="-march=aarch64-a+crypto"

# CORE="-mtune=cortex-a76 -mtune=cortex-a55"
CORE="CCCCCCCCCC"

OPTI="-Ofast -pthread -flto -fstrict-aliasing -ftree-vectorize -funroll-loops -ffinite-loops -finline-functions -fno-stack-protector -fomit-frame-pointer -fpic -falign-functions=64 -D_REENTRANT -mllvm -enable-loop-distribute"

./configure CXXFLAGS="$ARCH $CORE $OPTI" CFLAGS="$ARCH $CORE $OPTI" \
CXX=clang++ CC=clang  LDFLAGS="-Wl,-O3 -Wl,-hugetlbfs-align -fuse-ld=lld"
