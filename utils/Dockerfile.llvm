FROM ubuntu:12.04

# Used to build llvm and sub-packages
# See https://github.com/mapbox/mason/blob/master/scripts/llvm/base/README.md for details
# docker build -t mason-llvm -f utils/Dockerfile.llvm .
# docker run -it mason-llvm bash

# we mimic the travis path to ensure any hardcoded paths in deps
# do not cause problem's when building (an example is freetype-config)
ENV WORKINGDIR /home/travis/build/mapbox/mason/
WORKDIR ${WORKINGDIR}

RUN apt-get update -y && \
 apt-get install -y vim python build-essential bash curl git-core ca-certificates software-properties-common python-software-properties --no-install-recommends

# Note: we add the ubuntu-toolchain-r PPA to be able to upgrade to libstdc++6 below
# which is a runtime dependency of the build tools for llvm like cmake.
# We do not actually link or use libstdc++ for llvm tools (rather, on linux, they link their own libc++)
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update -y

# curses needed until https://github.com/mapbox/mason/issues/309 is solved.
RUN apt-get install -y libstdc++6 xutils-dev libncurses5-dev libz-dev pkg-config

RUN mkdir /home/travis/.ccache

COPY mason mason
COPY mason.sh mason.sh
COPY scripts scripts
COPY utils utils
