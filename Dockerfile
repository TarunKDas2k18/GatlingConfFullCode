# Gatling is a highly capable load testing tool.
#
# Documentation: https://gatling.io/docs/3.0/
# Cheat sheet: https://gatling.io/docs/3.0/cheat-sheet/

FROM openjdk:8-jdk-alpine

MAINTAINER Tarun Das 

# working directory for gatling
WORKDIR /opt

# gating version
ENV GATLING_VERSION 3.0.0

# create directory for gatling install
RUN mkdir -p gatling

RUN apk add git

RUN git clone https://github.com/TarunKDas2k18/gatlingconf.git /tmp/archivetd

RUN ls /tmp/archivetd

# install gatling
RUN apk add --update wget bash libc6-compat && \
  mkdir -p /tmp/downloads && \
  wget -q -O /tmp/downloads/gatling-$GATLING_VERSION.zip \
  https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/$GATLING_VERSION/gatling-charts-highcharts-bundle-$GATLING_VERSION-bundle.zip && \
  mkdir -p /tmp/archive && cd /tmp/archive && \
  unzip /tmp/downloads/gatling-$GATLING_VERSION.zip && \
  mv /tmp/archive/gatling-charts-highcharts-bundle-$GATLING_VERSION/* /opt/gatling/ && \
  ls /tmp/archivetd &&\
  cp /tmp/archivetd/*.* /opt/gatling/conf/ &&\
  find /opt/gatling/conf/ &&\
  rm -rf /tmp/*

# change context to gatling directory
WORKDIR  /opt/gatling

# set directories below to be mountable from host
#VOLUME ["c:\\gatling\\conf", "c:\\gatling\\results", "c:\\gatling\\user-files"]
VOLUME ["/opt/gatling/conf", "/opt/gatling/results", "/opt/gatling/user-files"]

# set environment variables
ENV PATH /opt/gatling/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GATLING_HOME /opt/gatling

ENTRYPOINT ["gatling.sh"]
