###########
# BUILDER #
###########
FROM ubuntu:18.04 as builder
# Declare container's arguments
ARG SOURCE_ORIGIN=https://github.com/boxycoin/boxycore.git
ARG COMMIT=51299e87949822ea5571e02bff780f4e32729ab0
ARG SOURCE_LOCAL_ROOT=/usr/src/wallet/boxycore
ARG DAEMON_NAME=boxycoind
ARG DATA_FOLDER=.boxycoin

WORKDIR /usr/src/wallet
# Install basic build tools
RUN apt-get update \
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
       libgmp-dev \
       ca-certificates \
       git \
       # Manually install libdb v5.3
       libdb5.3-dev libdb5.3++-dev
# Install select boost libraries
RUN apt-get install -y --no-install-recommends \
       libboost-all-dev \ 
       libdb++-dev \ 
       libboost-chrono-dev \
       libboost-filesystem-dev \
       libboost-program-options-dev \
       libboost-system-dev \
       libboost-test-dev \
       libboost-thread-dev
# Clone the proper git and commit
RUN git clone ${SOURCE_ORIGIN}
RUN cd ${SOURCE_LOCAL_ROOT} \
    && git checkout ${COMMIT}
# Install leveldb v1.18
RUN cd ${SOURCE_LOCAL_ROOT}/src/leveldb \
    && wget https://github.com/google/leveldb/archive/v1.18.tar.gz \
    && tar xfv v1.18.tar.gz \
    && cp leveldb-1.18/Makefile ${SOURCE_LOCAL_ROOT}/src/leveldb/ \
    && cd ${SOURCE_LOCAL_ROOT}/src \
    && chmod +x leveldb/build_detect_platform
# make the wallet's depends.
RUN cd ${SOURCE_LOCAL_ROOT}/depends && \
    make
# Make and install the Wallet
RUN cd ${SOURCE_LOCAL_ROOT} && \
    ./autogen.sh
RUN cd ${SOURCE_LOCAL_ROOT} && \
    ./configure --enable-upnp-default --with-unsupported-ssl --without-gui --with-incompatible-bdb
RUN cd ${SOURCE_LOCAL_ROOT} && \
    make
RUN cd ${SOURCE_LOCAL_ROOT}/src && \
    mv ${DAEMON_NAME} /usr/bin/ && \
    mv boxycoin-tx /usr/bin/ && \
    mv boxycoin-cli /usr/bin/

###########
#  FINAL  #
###########
FROM ubuntu:18.04
LABEL maintainer="The Boy*Roy container maintainers <j@theboyroy.com>"

ENV COIN=boxycoin
ENV DAEMON_NAME=boxycoind
ENV DATA_FOLDER=.boxycoin
ENV WALLET_HOME=/home/${COIN}/${DATA_FOLDER}
ENV BIN_HOME=/usr/bin

WORKDIR ${BIN_HOME}

RUN useradd -m -s /bin/bash -u 1001 ${COIN}

COPY --from=builder ${BIN_HOME}/${DAEMON_NAME} .
COPY --from=builder ${BIN_HOME}/${COIN}-cli .
COPY --from=builder ${BIN_HOME}/${COIN}-tx .
COPY --from=builder /usr/lib/* /usr/lib/

COPY ./entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh

WORKDIR /home/${COIN}
USER ${COIN}
RUN mkdir ${DATA_FOLDER} \
 && chmod 700 ${DATA_FOLDER}

COPY ./boxycoin.conf /home/${COIN}/

VOLUME ${WALLET_HOME}

EXPOSE 8332 8333

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
