# Create a abcd docker container 
#
# Note: The resulting container is ~22GB. 
# 
# Example build:
#   docker build --no-cache -t abcd:254 -f Dockerfile .
#
# In order to install matlab correctly we need a license file and a file installation key
#   docker build --no-cache --build-arg fileInstallationKey=12345  -t abcd:254 -f Dockerfile .

# Start with debian
FROM debian:bullseye-slim
#MAINTAINER Feng Xue <xfgavin@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# specify a matlab file installation key (install without network)
#   --build-arg fileInstallationKey=12345-12323-.....
ARG fileInstallationKey

ADD abcddocker_installer.sh /tmp
COPY fslinstaller.py /tmp
COPY MMPS_254.tar /tmp
RUN mkdir -p /usr/pubsw/packages/MMPS && cd /usr/pubsw/packages/MMPS && tar -xvf /tmp/MMPS_254.tar

RUN /tmp/abcddocker_installer.sh 254

#
# Install matlab inside the container
# The R2021b_install_folder.tar has been downloaded using the Matlab
# installer application. Set "advanced" and "download only" to get this (large) folder.
#
RUN mkdir -p /usr/pubsw/packages/matlab
COPY network.lic /usr/pubsw/packages/matlab/
COPY R2021b_install_folder.tar /tmp
RUN cd /tmp/ && tar xvf R2021b_install_folder.tar \
    && cd /usr/pubsw/packages/matlab/ \
    && cp /tmp/R2021b/2022_07_27_11_14_55/installer_input.txt /tmp/ \
    && sed -i -r 's+# destinationFolder=+destinationFolder=/usr/pubsw/packages/matlab/R2021b/+' /tmp/installer_input.txt \
    && sed -i -r "s+# fileInstallationKey=+fileInstallationKey=${fileInstallationKey}+" /tmp/installer_input.txt \
    && sed -i -r 's+# agreeToLicense=+agreeToLicense=yes+' /tmp/installer_input.txt \
    && sed -i -r 's+# licensePath=+licensePath=/usr/pubsw/packages/matlab/network.lic+' /tmp/installer_input.txt \
    && cd /tmp/R2021b/2022_07_27_11_14_55 \
    && ./install -inputFile /tmp/installer_input.txt \
    && rm -rf /tmp/R2021b \
    && rm -rf /tmp/R2021b_install_folder.tar \
    && rm -rf /tmp/installer_input.txt
#Clean up after matlab install

#RUN ln -s /usr/pubsw/packages/matlab/network.lic /usr/pubsw/packages/matlab/R2021b/licenses/network.lic

COPY atlases.2020.10.14.tar /tmp
RUN mkdir -p /usr/pubsw/packages/MMPS/atlases \
    && cd /usr/pubsw/packages/MMPS/atlases \
    && tar -xvf /tmp/atlases.2020.10.14.tar \
    && rm -rf /tmp/atlases.2020.10.14.tar

COPY usr_pubsw_bin.zip /tmp
RUN cd /usr/pubsw \
    && unzip /tmp/usr_pubsw_bin \
    && rm -rf /tmp/usr_pubsw_bin.zip

# replace some of the bin files with our copies
COPY pubsw_bin/SetUpFreeSurfer.csh /usr/pubsw/bin/
COPY pubsw_bin/SetUpAFNI.csh /usr/pubsw/bin/
COPY pubsw_bin/SetUpFSL.csh /usr/pubsw/bin/
COPY pubsw_bin/SetUpMMPS.csh /usr/pubsw/bin/
COPY pubsw_bin/SetUpMatlab.csh /usr/pubsw/bin/

COPY mmps_home.tar.gz /tmp
RUN cd /tmp/ \
    && gunzip mmps_home.tar.gz \
    && tar xvf /tmp/mmps_home.tar \
    && mkdir -p /home/MMPS \
    && cd /home/MMPS \
    && mv /tmp/mmps_home/* . \
    && mv /tmp/mmps_home/.cshrc . \
    && chown -R MMPS /home/MMPS \
    && rm -rf /tmp/mmps_home

COPY cshrc /home/MMPS/.cshrc
RUN chown MMPS:MMPS /home/MMPS/.cshrc

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
CMD /bin/tcsh -l
#ENTRYPOINT ["/usr/pubsw/packages/MMPS/MMPS_254/sh/abcd_init.sh"]
ENV DEBIAN_FRONTEND teletype