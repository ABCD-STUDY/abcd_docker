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


COPY R2014b_installed.tar /tmp
RUN mkdir -p /usr/pubsw/packages/matlab \
    && cd /usr/pubsw/packages/matlab/ \
    && tar -xvf /tmp/R2014b_installed.tar \
    && rm -rf /usr/pubsw/packages/matlab/R2014b/licenses/network.lic

COPY network.lic /usr/pubsw/packages/matlab/
RUN ln -s /usr/pubsw/packages/matlab/network.lic /usr/pubsw/packages/matlab/R2014b/licenses/network.lic

COPY atlases.2020.10.14.tar /tmp
RUN mkdir -p /usr/pubsw/packages/MMPS/atlases \
    && cd /usr/pubsw/packages/MMPS/atlases \
    && tar -xvf /tmp/atlases.2020.10.14.tar

#RUN apt update && apt-get install -qq tcsh
RUN /tmp/abcddocker_installer.sh 254

COPY usr_pubsw_bin.zip /tmp
RUN cd /usr/pubsw \
    && unzip /tmp/usr_pubsw_bin

# replace some of the bin files with our copies
#COPY pubsw_bin/SetUpFreeSurfer.csh /usr/pubsw/bin/

COPY mmps_home.tar.gz /tmp
RUN cd /tmp/ && gunzip mmps_home.tar.gz && tar xvf /tmp/mmps_home.tar \
    && mkdir -p /home/MMPS \
    && cd /home/MMPS \
    && mv /tmp/mmps_home/* . \
    && mv /tmp/mmps_home/.cshrc . \
    && chown -R MMPS /home/MMPS \
    && rm -rf /tmp/mmps_home

#COPY cshrc /home/MMPS/.cshrc
RUN chown MMPS /home/MMPS/.cshrc

ENV NAME "ABCD Processing Pipeline based on MMPS V254"
ENV VER "254_2022"
ENV MMPSVER "254"
ENV USER "MMPS"
ENV HOME "/home/MMPS"
#############################################################################
#The abcd_init.sh will creat an MMPS user with uid equals current user
#So data should be mounted to /home/MMPS
#############################################################################
USER MMPS
WORKDIR /home/MMPS
#ENTRYPOINT ["/usr/pubsw/packages/MMPS/MMPS_254/sh/abcd_init.sh"]
ENV DEBIAN_FRONTEND teletype
