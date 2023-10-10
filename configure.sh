#!/bin/bash

ARCH="-march=AAAAAAAAAA-a+crypto"

CORE="CCCCCCCCCC"

OPTI="-Ofast -pthread -flto -fstrict-aliasing -ftree-vectorize -funroll-loops \
-ffinite-loops -finline-functions -fno-stack-protector -fomit-frame-pointer -fpic \
-falign-functions=64 -D_REENTRANT -mllvm -enable-loop-distribute"

./configure CXXFLAGS="$ARCH $CORE $OPTI" CFLAGS="$ARCH $CORE $OPTI" \
CXX=clang++ CC=clang  LDFLAGS="-Wl,-O3 -Wl,-hugetlbfs-align -fuse-ld=lld"
