# Create a abcd docker container 
#
# Note: The resulting container is ~22GB. 
# 
# Example build:
#   docker build --no-cache -t abcd:254 .
#

# Start with debian
FROM debian:bullseye-slim
MAINTAINER Feng Xue <xfgavin@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ADD abcddocker_installer.sh /tmp
COPY fslinstaller.py /tmp
COPY MMPS_254.tar /tmp
RUN mkdir -p /usr/pubsw/packages/MMPS && cd /usr/pubsw/packages/MMPS && tar -xvf /tmp/MMPS_254.tar

COPY atlases.2020.10.14.tar /tmp
RUN mkdir -p /usr/pubsw/packages/MMPS/atlases && cd /usr/pubsw/packages/MMPS/atlases && tar -xvf /tmp/atlases.2020.10.14.tar

RUN /tmp/abcddocker_installer.sh 254

COPY mmps_home.tar.gz /tmp
RUN cd /tmp/ && gunzip mmps_home.tar.gz && tar xvf /tmp/mmps_home.tar && cd /home && mv /tmp/mmps_home/* . && rm -rf /tmp/mmps_home

ENV NAME "ABCD Processing Pipeline based on MMPS V254"
ENV VER "254_2022"
ENV MMPSVER "254"
ENV USER "MMPS"
ENV HOME "/home/MMPS"
#############################################################################
#The abcd_init.sh will creat an MMPS user with uid equals current user
#So data should be mounted to /home/MMPS
#############################################################################

ENTRYPOINT ["/usr/pubsw/packages/MMPS/MMPS_254/sh/abcd_init.sh"]
ENV DEBIAN_FRONTEND teletype
