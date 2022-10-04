#!/usr/bin/env bash
MMPSVER=$1
[ ${#MMPSVER} -eq 0 ] && echo "MMPS Version is invalid" && exit -1
padzero(){
  case ${#1} in
    1)
      echo "0$1"
      ;;
    *)
      echo "$1"
      ;;
  esac
}
date
mkdir -p /scratch
mkdir -p /data
mkdir -p /oasis
mkdir -p /projects

debian="bullseye"

echo "**********************************************"
echo "*Installing prerequisites                    *"
echo "**********************************************"
apt-get -qq update >/dev/null 2>&1
apt-get install -qq --no-install-recommends --allow-unauthenticated apt-utils >/dev/null 2>&1
apt-get -qq --allow-unauthenticated install tar aria2 libgomp1 graphicsmagick-libmagick-dev-compat libmotif-dev libxpm-dev libglu1-mesa-dev libglw1-mesa-dev libgsl-dev libxt-dev libxrandr2 libxcursor-dev libxinerama-dev libxft-dev libxmu-dev libxi-dev libglu1-mesa bc bzip2 dc file libsm6 tcsh unzip libx11-6 libxext6 libgomp1 libexpat1 libgl1-mesa-glx libxt6 jq curl libstdc++6 binutils lrzip dcmtk python2 python3 python3-pip pigz libncurses5 xvfb xfstt man-db x11-apps >/dev/null
# Just during development we would need these... 
apt-get -qq install nano vim
pip3 -q --no-cache-dir install pydicom dicom pandas matplotlib scipy
#echo "deb http://archive.debian.org/debian-archive/debian jessie main contrib non-free" > /etc/apt/sources.list
echo "deb http://deb.debian.org/debian $debian main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian $debian main contrib non-free" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security/ $debian/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian-security/ $debian/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian $debian-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian $debian-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian $debian-backports main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian $debian-backports main contrib non-free" >> /etc/apt/sources.list
#echo "deb http://security.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list
apt-get -qq update >/dev/null
apt-get -qq --allow-unauthenticated install libxpm4 libpng16-16 >/dev/null
apt-get -qq install --allow-unauthenticated git build-essential cmake git pkg-config >/dev/null
aria2c -q -d /tmp -o libg2c0_3.4.6-8ubuntu2_amd64.deb http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-3.4/libg2c0_3.4.6-8ubuntu2_amd64.deb
dpkg -x /tmp/libg2c0_3.4.6-8ubuntu2_amd64.deb /tmp/
mv /tmp/usr/lib/libg2c* /usr/lib/
rm -rf /tmp/usr
mkdir -p /usr/pubsw/packages/freesurfer
mkdir -p /usr/pubsw/packages/afni/AFNI_2010_10_19_1028
mkdir -p /usr/pubsw/packages/fsl
mkdir -p /usr/pubsw/packages/mcr
mkdir -p /usr/pubsw/packages/dtitk
mkdir -p /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin

# We need python 2.7 as well, not just python3
apt-get -qq install python

echo "**********************************************"
echo " Create an MMPS user account with tcsh        "
echo "**********************************************"
useradd -s /bin/tcsh -d /home/MMPS MMPS


date
echo "**********************************************"
echo "*Installing Freesurfer centos8_x86_64-v7.1.1 *"
echo "**********************************************"
aria2c -q -x 10 -s 10 -d /tmp -o freesurfer-linux-centos8_x86_64-7.1.1.tar.gz ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.1.1/freesurfer-linux-centos8_x86_64-7.1.1.tar.gz
tar -xf /tmp/freesurfer-linux-centos8_x86_64-7.1.1.tar.gz -C /usr/pubsw/packages/freesurfer/
mv /usr/pubsw/packages/freesurfer/freesurfer /usr/pubsw/packages/freesurfer/RH8-x86_64-R711

date
echo "**********************************************"
echo "*Installing FSL  6.0.5.2-centos7_64          *"
echo "**********************************************"
/usr/bin/python2.7 /tmp/fslinstaller.py -q -B 6.0.5.2 -d /usr/pubsw/packages/fsl/fsl-6.0.5.2-ubuntu

#for ((i=0;i<=13;i++))
#do
#  aria2c -q -x 10 -s 10 -d /tmp/fsl -o fsl-5.0.2.2-centos6_64.tgz`padzero $i` https://github.com/xfgavin/abcd_docker_mmps/raw/master/packages/fsl-5.0.2.2-centos6_64.tgz`padzero $i`
#done
#cat /tmp/fsl/fsl-5.0.2.2-centos6_64.tgz* >/tmp/fsl/fsl-5.0.2.2-centos6_64.tgz
#tar xf /tmp/fsl/fsl-5.0.2.2-centos6_64.tgz -C /usr/pubsw/packages/fsl/
#date
#echo "**********************************************"
#echo "*Installing FSL 5.0.6-centos6_64             *"
#echo "**********************************************"
#aria2c -q -x 10 -s 10 -d /tmp -o fsl-5.0.6-centos6_64.tar.gz https://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/fsl-5.0.6-centos6_64.tar.gz
#tar -xf /tmp/fsl-5.0.6-centos6_64.tar.gz -C /usr/pubsw/packages/fsl/
#mv /usr/pubsw/packages/fsl/fsl /usr/pubsw/packages/fsl/fsl-5.0.6-centos6_64

#already have matlab 2021
#date
#echo "**********************************************"
#echo "*Installing MATLAB run time v84 (R2014b)     *"
#echo "**********************************************"
#aria2c -q -x 10 -s 10 -d /tmp/mcr -o mcr.zip http://ssd.mathworks.com/supportfiles/downloads/R2014b/deployment_files/R2014b/installers/glnxa64/MCR_R2014b_glnxa64_installer.zip
#unzip -qq /tmp/mcr/mcr.zip -d /tmp/mcr
#/tmp/mcr/install -destinationFolder /usr/pubsw/packages/mcr/v84 -agreeToLicense yes -mode silent >/dev/null

date
echo "**********************************************"
echo "*Installing AFNI 2010_10_19_1028             *"
echo "**********************************************"
cd /tmp/
curl -O https://afni.nimh.nih.gov/pub/dist/tgz/linux_ubuntu_16_64.tgz
tar zxfv /tmp/linux_ubuntu_16_64.tgz 
mv /tmp/linux_ubuntu_16_64/* /usr/pubsw/packages/afni/AFNI_2010_10_19_1028/

#for ((i=0;i<=3;i++))
#do
#  aria2c -q -x 10 -s 10 -d /tmp/afni -o AFNI_2010_10_19_1028.tgz0$i https://github.com/xfgavin/abcd_docker_mmps/raw/master/packages/AFNI_2010_10_19_1028.tgz0$i
#done
#cat /tmp/afni/AFNI_2010_10_19_1028.tgz00 /tmp/afni/AFNI_2010_10_19_1028.tgz01 /tmp/afni/AFNI_2010_10_19_1028.tgz02 /tmp/afni/AFNI_2010_10_19_1028.tgz03 > /tmp/afni/AFNI_2010_10_19_1028.tgz
#tar xf /tmp/afni/AFNI_2010_10_19_1028.tgz -C /usr/pubsw/packages/afni/AFNI_2010_10_19_1028

date
echo "**********************************************"
echo "*Installing MMPS 254                         *"
echo "**********************************************"
#for ((i=0;i<=28;i++))
#do
#  aria2c -q -x 10 -s 10 -d /tmp/mmps_perpheral_mmps -o mmps_perpheral_mmps.tgz.lrz`padzero $i` https://github.com/xfgavin/abcd_docker_mmps/raw/master/packages/mmps_perpheral/mmps_perpheral_mmps.tgz.lrz`padzero $i`
#done
#cat /tmp/mmps_perpheral_mmps/mmps_perpheral_mmps.tgz.lrz* > /tmp/mmps_perpheral_mmps/mmps_perpheral_mmps.tgz.lrz
#lrzip -d -q -O /tmp/mmps_perpheral_mmps/ /tmp/mmps_perpheral_mmps/mmps_perpheral_mmps.tgz.lrz
#tar xf /tmp/mmps_perpheral_mmps/mmps_perpheral_mmps.tgz -C /usr/pubsw/packages
#
#for ((i=0;i<=10;i++))
#do
#  aria2c -q -x 10 -s 10 -d /tmp/mmps_engine -o mmps_engine.lrz`padzero $i` https://github.com/xfgavin/abcd_docker_mmps/raw/master/mmps_engine/mmps_engine.lrz`padzero $i`
#done
#cat /tmp/mmps_engine/mmps_engine.lrz* > /tmp/mmps_engine/mmps_engine.lrz
#lrzip -d -q -O /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin/ /tmp/mmps_engine/mmps_engine.lrz
#chmod +x /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin/mmps_engine

#for ((i=0;i<=1;i++))
#do
#  aria2c -q -x 10 -s 10 -d /tmp/mmps -o mmps_$MMPSVER.tgz`padzero $i` https://github.com/xfgavin/abcd_docker_mmps/raw/master/mmps/mmps_$MMPSVER.tgz`padzero $i`
#done
#cat /tmp/mmps/mmps_$MMPSVER.tgz* > /tmp/mmps/mmps_$MMPSVER.tgz
#tar xf /tmp/mmps/mmps_$MMPSVER.tgz -C /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/

#aria2c -q -x 10 -s 10 -d /tmp -o mmps_perpheral_other.tgz https://github.com/xfgavin/abcd_docker_mmps/raw/master/packages/mmps_perpheral/mmps_perpheral_other.tgz
#tar xf /tmp/mmps_perpheral_other.tgz -C /usr/pubsw/packages/

#aria2c -q -x 1 -s 1 -d /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh -o abcd_init.sh https://raw.githubusercontent.com/xfgavin/abcd_docker_mmps/master/scripts/abcd_init.sh
#aria2c -q -x 1 -s 1 -d /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh -o mmps_fsurf.sh https://raw.githubusercontent.com/xfgavin/abcd_docker_mmps/master/scripts/mmps_fsurf.sh

#rm -f /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh/run_all_MMPS.sh
#aria2c -q -x 1 -s 1 -d /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh -o run_all_MMPS.sh https://raw.githubusercontent.com/xfgavin/abcd_docker_mmps/master/scripts/run_all_MMPS.sh
#rm -f /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh/getValue.sh
#aria2c -q -x 1 -s 1 -d /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh -o getValue.sh https://raw.githubusercontent.com/xfgavin/abcd_docker_mmps/master/scripts/getValue.sh
#aria2c -q -x 1 -s 1 -d /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh -o run_mmps_engine.sh https://raw.githubusercontent.com/xfgavin/abcd_docker_mmps/master/scripts/run_mmps_engine.sh
#chmod +x /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh/*.sh

ln -s /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin/mmps_engine /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/sh/

#aria2c -q -x 1 -s 1 -d /tmp -o mmps_setupscripts.tgz https://raw.githubusercontent.com/xfgavin/abcd_docker_mmps/master/mmps/mmps_setupscripts.tgz
#tar xf /tmp/mmps_setupscripts.tgz -C /usr/pubsw
#chmod +x /usr/pubsw/bin/*

aria2c -q -x 10 -s 10 -d /tmp/ -o dtitk-2.3.1-Linux-x86_64.tar.gz https://github.com/xfgavin/abcd_docker_mmps/raw/master/packages/dtitk-2.3.1-Linux-x86_64.tar.gz
tar xf /tmp/dtitk-2.3.1-Linux-x86_64.tar.gz -C /usr/pubsw/packages/dtitk

date
echo "**********************************************"
echo "*Installing dcm2niix                         *"
echo "**********************************************"
aria2c -q -x 10 -s 10 -d /tmp/ -o dcm2niix.zip https://github.com/rordenlab/dcm2niix/archive/master.zip
(
cd /tmp
unzip /tmp/dcm2niix.zip >/dev/null
mkdir -p /tmp/dcm2niix-master/build
cd /tmp/dcm2niix-master/build
sed -e "s/opts->isFlipY = true/opts->isFlipY = false/g" -i ../console/nii_dicom_batch.cpp
cmake .. >/dev/null
make >/dev/null
mv bin/dcm2niix /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin/dcm2niix_noflipY
rm /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin/dcm2niix
ln -s dcm2niix_noflipY /usr/pubsw/packages/MMPS/MMPS_$MMPSVER/bin/dcm2niix
)

aria2c -q -x 10 -s 10 -d /usr/local/bin -o gosu https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64
chmod +x /usr/local/bin/gosu


ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/lib/x86_64-linux-gnu/libtiff.so.3
ln -s /usr/lib/libMagick.so /usr/lib/libMagick.so.6   ##For im_convert in MMPS
sed -e "s#^root.*#root:*:0:0:root:/root:/bin/tcsh#g" -i /etc/passwd
date
echo "**********************************************"
echo "*Cleaning up                                 *"
echo "**********************************************"
apt-get -qq purge aria2 netbase manpages iputils-ping iproute2 gcc cpp cpp-6 gcc-6 git build-essential cmake pkg-config cmake-data tcpd>/dev/null
apt-get -qq autoremove >/dev/null
apt-get install -qq --allow-unauthenticated  --no-install-recommends --allow-downgrades perl-base=5.20.2-3+deb8u12 perl-modules perl=5.20.2-3+deb8u12 >/dev/null 2>&1
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
chmod -R 777 /tmp
rm -f /bin/sh
ln -s bash /bin/sh
