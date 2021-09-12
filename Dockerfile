###########
# BUILDER #
###########

FROM ubuntu:18.04

ENV SOURCE_ORIGIN https://github.com/boxycoin/boxycore.git
ENV COMMIT 51299e87949822ea5571e02bff780f4e32729ab0

ARG SOURCE_LOCAL_ROOT=/usr/src/wallet/boxycore
ARG DAEMON_NAME=boxycoind
ARG DATA_FOLDER=.boxycoin

WORKDIR /usr/src/wallet
RUN apt-get update \
    #  basic build tools
    && apt-get install -y --no-install-recommends \
       build-essential \
       bsdmainutils \
       curl \
       libssl-dev \
       libtool \
       openssl \
       pkg-config \
       wget \
       python-dev \
       python3 \
       autotools-dev \
       software-properties-common \
       autoconf \
       automake \
       libzmq3-dev \
       libminiupnpc-dev \
       libevent-dev \
       libgmp-dev
    #  select boost libraries
RUN apt-get install -y --no-install-recommends \
       libboost-all-dev \ 
       libdb++-dev \ 
    #    libssl-dev \ 
       libboost-chrono-dev \
       libboost-filesystem-dev \
       libboost-program-options-dev \
       libboost-system-dev \
       libboost-test-dev \
       libboost-thread-dev
    #  wallet db v4.8 repository
# RUN add-apt-repository ppa:bitcoin/bitcoin && apt-get update
    #  wallet db v4.8 install
RUN apt-get install -y libdb5.3-dev libdb5.3++-dev
    #  Git source code
RUN apt-get install -y --no-install-recommends \
       ca-certificates \
       git 
RUN git clone ${SOURCE_ORIGIN}
RUN cd ${SOURCE_LOCAL_ROOT} \
    #  Use a GREEN commit
    && git checkout ${COMMIT}
    #  build the wallet
# COPY src/ ${SOURCE_LOCAL_ROOT}/src
RUN cd ${SOURCE_LOCAL_ROOT}/src/leveldb \
    && wget https://github.com/google/leveldb/archive/v1.18.tar.gz \
    && tar xfv v1.18.tar.gz \
    && cp leveldb-1.18/Makefile ${SOURCE_LOCAL_ROOT}/src/leveldb/ \
    && cd ${SOURCE_LOCAL_ROOT}/src \
    && chmod +x leveldb/build_detect_platform
RUN cd ${SOURCE_LOCAL_ROOT}/depends && \
    make
RUN cd ${SOURCE_LOCAL_ROOT} && \
    ./autogen.sh

RUN cd ${SOURCE_LOCAL_ROOT} && \
    ./configure --enable-upnp-default --with-unsupported-ssl --without-gui --with-incompatible-bdb
# RUN cd ${SOURCE_LOCAL_ROOT}/src && \
#     make -f makefile.unix
RUN cd ${SOURCE_LOCAL_ROOT} && \
    make

# RUN cp ${SOURCE_LOCAL_ROOT}/src/${DAEMON_NAME} /usr/bin
RUN cd ${SOURCE_LOCAL_ROOT} && \
    make install