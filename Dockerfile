FROM ubuntu:14.04

MAINTAINER jmclaughlin@kodacall.com

RUN apt-get update; \
    apt-get install -y build-essential curl

RUN apt-get install -y autoconf libgnutls-dev libxml2-dev \
    libncurses5-dev subversion doxygen texinfo \
    libcurl4-gnutls-dev libsnmp-dev libneon27-dev

RUN apt-get install -y uuid-dev libsqlite3-dev sqlite \
    git libspeex-dev libsqlite0-dev

RUN mkdir -p /usr/src/asterisk

WORKDIR /usr/src/asterisk

RUN cd /usr/src/asterisk && \
    curl -s http://srtp.sourceforge.net/srtp-1.4.2.tgz | tar xzf - && \
    cd srtp && \
    autoconf && \
    ./configure CFLAGS=-fPIC --prefix=/usr && \
    make && \
    make install

RUN cd /usr/src/asterisk && \
    curl -s http://www.digip.org/jansson/releases/jansson-2.5.tar.gz | tar xzf - && \
    cd jansson-2.5 && \
    ./configure --prefix=/usr && make && make install

RUN cd /usr/src/asterisk && \
    curl -s http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz | tar xzf - && \
    cd asterisk-13* && make clean && \
    ./configure --prefix=/usr --with-crypto --with-ssl --with-srtp && \
    contrib/scripts/get_mp3_source.sh 

RUN cd /usr/src/asterisk/asterisk-13* && \
    make menuselect.makeopts && \
    menuselect/menuselect --enable format_mp3 --enable res_config_mysql --enable app_mysql --enable cdr_mysql --enable EXTRA-SOUNDS-EN-GSM

RUN cd /usr/src/asterisk/asterisk-13* && \
    make && make install && make samples && make config

