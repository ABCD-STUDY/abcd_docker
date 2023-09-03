# Create a abcd docker container 
#
# Note: The resulting container is ~22GB. 
# 
# Example build:
#   docker build --no-cache -t abcd:254 -f Dockerfile .
#
# In order to install matlab correctly we need a license file and a file installation key
#   docker build --no-cache --build-arg fileInstallationKey=12345  -t abcd:254 -f Dockerfile .

# Njål comments 2023:
# converted .tar and .zip to .tar.gz
# fixed some compressed files which unpacked to subfolder :/
# one-step ADD instead of COPY and RUN with extract, which increase size of image
# RUN with mount, so install files doesn't add to image size
# original steps left for reference
# added "set -e" to abcd_installer.sh to halt on errors, removed >/dev/null so we get errors

# Start with debian
FROM --platform=amd64 debian:bullseye-slim
#MAINTAINER Feng Xue <xfgavin@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

#COPY files/ /tmp
#COPY abcddocker_installer.sh /tmp
#COPY fslinstaller.py /tmp

ADD extract/MMPS_254.tar.gz /usr/pubsw/packages/MMPS
#COPY MMPS_254.tgz /tmp
#RUN mkdir -p /usr/pubsw/packages/MMPS && cd /usr/pubsw/packages/MMPS && tar -xzvf /tmp/MMPS_254.tgz

# RUN ABCDdocker-installer to set up environment
RUN --mount=type=bind,target=/install,source=install/abcd/ /install/abcddocker_installer.sh 254

# INSTALL FSL 6.0.5.2
RUN --mount=type=bind,target=/install,source=install/fsl/ /usr/bin/python2.7 /install/fslinstaller.py -f /install/fsl-6.0.5.2-install-yml-change-order.tar.gz -M -d /usr/pubsw/packages/fsl/fsl-6.0.5.2-ubuntu

# EXTRACT FS 7.1.1
# must use RUN and manually extract, since files are in freesurfer/ folder in tar file
RUN --mount=type=bind,target=/extract,source=extract/ \
    mkdir -p /usr/pubsw/packages/freesurfer/RH8-x86_64-R711 && \
    tar -zxf /extract/freesurfer-linux-centos8_x86_64-7.1.1.tar.gz --strip-components=1 --no-same-owner -C $_

# EXTRACT AFNI_2010_10_19_1028
RUN --mount=type=bind,target=/extract,source=extract/ \
    mkdir -p /usr/pubsw/packages/afni/AFNI_2010_10_19_1028 && \
    tar -zxf /extract/linux_ubuntu_16_64.tgz --strip-components=1 -C $_
#ADD extract/linux_ubuntu_16_64.tgz /usr/pubsw/packages/afni/
#RUN mv /usr/pubsw/packages/afni/linux_ubuntu_16_64 /usr/pubsw/packages/afni/AFNI_2010_10_19_1028

# EXTRACT dtitk
ADD extract/dtitk-2.3.1-Linux-x86_64.tar.gz /usr/pubsw/packages/dtitk

# EXTRACT atlases
ADD extract/atlases.2020.10.14.tar.gz /usr/pubsw/packages/MMPS/atlases/
#COPY atlases.2020.10.14.tar /tmp
#RUN mkdir -p /usr/pubsw/packages/MMPS/atlases \
#    && cd /usr/pubsw/packages/MMPS/atlases \
#    && tar -xvf /tmp/atlases.2020.10.14.tar \
#    && rm -rf /tmp/atlases.2020.10.14.tar

ADD extract/usr_pubsw_packages_opt.tar.gz /usr/pubsw/packages/opt/
#COPY usr_pubsw_packages_opt.tar /tmp
#RUN mkdir -p /usr/pubsw/packages/opt/ \
#    && cd /usr/pubsw/packages/opt/ \
#    && tar -xvf /tmp/usr_pubsw_packages_opt.tar \
#    && rm -rf /tmp/usr_pubsw_packages_opt.tar

ADD --chown=MMPS extract/usr_pubsw_bin.tar.gz /usr/pubsw/
#COPY usr_pubsw_bin.zip /tmp
#RUN cd /usr/pubsw \
#    && unzip /tmp/usr_pubsw_bin \
#    && rm -rf /tmp/usr_pubsw_bin.zip

# replace some of the bin files with our copies
COPY --chown=MMPS files/pubsw_bin/ /usr/pubsw/bin/
#COPY pubsw_bin/SetUpFreeSurfer.csh /usr/pubsw/bin/
#COPY pubsw_bin/SetUpAFNI.csh /usr/pubsw/bin/
#COPY pubsw_bin/SetUpFSL.csh /usr/pubsw/bin/
#COPY pubsw_bin/SetUpMMPS.csh /usr/pubsw/bin/
#COPY pubsw_bin/SetUpMatlab.csh /usr/pubsw/bin/

# populate home directory
ADD --chown=MMPS extract/mmps_home.tar.gz /home/MMPS
#COPY mmps_home.tar.gz /tmp
#RUN cd /tmp/ \
#    && gunzip mmps_home.tar.gz \
#    && tar xvf /tmp/mmps_home.tar \
#    && mkdir -p /home/MMPS \
#    && mkdir -p /home/MMPS/matlab/ \
#    && mkdir -p /home/MMPS/batchdirs \
#    && cd /home/MMPS \
#    && mv /tmp/mmps_home/* . \
#    && mv /tmp/mmps_home/.cshrc . \
#    && chown -R MMPS /home/MMPS \
#    && rm -rf /tmp/mmps_home

ARG fileInstallationKey
RUN --mount=type=bind,target=/install,source=install/matlab --mount=type=tmpfs,target=/tmp\
    cd /tmp && \
    tar -zxf /install/matlab_r2021b.tar.gz&& \
    sed -i -r 's+# destinationFolder=+destinationFolder=/usr/pubsw/packages/matlab/R2021b/+' installer_input.txt && \
    sed -i -r "s+# fileInstallationKey=+fileInstallationKey=${fileInstallationKey}+" installer_input.txt && \
    sed -i -r 's+# agreeToLicense=+agreeToLicense=yes+' installer_input.txt && \
    ./install -inputFile installer_input.txt

#COPY install/matlab_r2021b.tar.gz /install/
#RUN --mount=type=bind,target=/install,source=install/ \
#    cd /tmp && \
#    tar -zxf /install/matlab_r2021b.tar.gz && \
#    sed -i -r 's+# destinationFolder=+destinationFolder=/usr/pubsw/packages/matlab/R2021b/+' /tmp/installer_input.txt && \
#    sed -i -r 's+# agreeToLicense=+agreeToLicense=yes+' /tmp/installer_input.txt && \
#    ./install -inputFile /tmp/installer_input.txt && \
#    rm -rf *
# #
# # Install matlab inside the container
# # The R2021b_install_folder.tar has been downloaded using the Matlab
# # installer application. Set "advanced" and "download only" to get this (large) folder.
# #
# specify a matlab file installation key (install without network)
#   --build-arg fileInstallationKey=12345-12323-.....
#ARG fileInstallationKey
# RUN mkdir -p /usr/pubsw/packages/matlab
# COPY network.lic /usr/pubsw/packages/matlab/
# COPY R2021b_install_folder.tar.gz /tmp
#RUN cd /tmp/ && tar xvf R2021b_install_folder.tar \
#     && cd /usr/pubsw/packages/matlab/ \
#     && cp /tmp/R2021b/2022_07_27_11_14_55/installer_input.txt /tmp/ \
#     && sed -i -r 's+# destinationFolder=+destinationFolder=/usr/pubsw/packages/matlab/R2021b/+' /tmp/installer_input.txt \
#     && sed -i -r "s+# fileInstallationKey=+fileInstallationKey=${fileInstallationKey}+" /tmp/installer_input.txt \
#     && sed -i -r 's+# agreeToLicense=+agreeToLicense=yes+' /tmp/installer_input.txt \
#     && sed -i -r 's+# licensePath=+licensePath=/usr/pubsw/packages/matlab/network.lic+' /tmp/installer_input.txt \
#     && cd /tmp/R2021b/2022_07_27_11_14_55 \
#     && ./install -inputFile /tmp/installer_input.txt \
#     && rm -rf /tmp/R2021b \
#     && rm -rf /tmp/R2021b_install_folder.tar \
#     && rm -rf /tmp/installer_input.txt
# #Clean up after matlab install

# #RUN ln -s /usr/pubsw/packages/matlab/network.lic /usr/pubsw/packages/matlab/R2021b/licenses/network.lic

COPY --chown=MMPS files/home/ /home/MMPS/

COPY --chown=MMPS files/external.2021.02.09 /usr/pubsw/packages/MMPS/external/external.2021.02.09

# Add licenses
ADD license/freesurfer/license.txt /usr/pubsw/packages/freesurfer/RH8-x86_64-R711/
ADD license/matlab/license.lic /usr/pubsw/packages/matlab/R2021b/licenses/license_R2021b.lic

# Matlab needs libxtst6 for java to work
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y locate libxtst6 && \
    updatedb

# Setup the virtual X server
# RUN apt -qq install xvfb

# fix for broken python scripts using old style pydicom
# TODO: add to MMPS
COPY install/abcd/dicom_heads_get.py /usr/pubsw/packages/MMPS/MMPS_254/python/
COPY install/abcd/count_valid_dicom.py /usr/pubsw/packages/MMPS/MMPS_254/python/
ADD files/DAL_ABCD /home/MMPS/ProjInfo/DAL_ABCD

# topup needs libquadmath0 installed to work (DTI processing)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y libquadmath0

# fix locale
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN mkdir -p ~/data ~/MetaData/DAL_ABCD/cache && \
    cd ~/data && \
    mkdir -p orig incoming raw fsurf fsico aux_incoming proc proc_bold proc_dti pc qc unpack long



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