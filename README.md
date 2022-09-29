# ABCD docker (Ver: 254)

## Overview
The Multi-Modal Processing Stream (MMPS) is a software package that consists of binaries, scripts, and
matlab functions, designed collectively to process data from non-invasive brain imaging methods. These
modalities include structural MRI (sMRI; T1w, T2w), diffusion tensor imaging (dMRI; DTI, restriction spectrum
imaging), resting-state functional MRI (rs-fMRI), and task-based fMRI (task-fMRI), representing a range of
temporal and spatial resolutions, physiological and anatomical sensitivities, and fields of view. The challenge
therein is to combine simultaneous and complementary information from different imaging techniques in order
to provide comprehensive analyses across a variety of research applications; the MMPS provides a simple
yet powerful interface to do just this, and has aided the understanding of normal function in sleep, memory
and language, development and aging, and diseases such as dementia, epilepsy, and autism.
The tools in this package were written by several members of the University of California, San Diego
Multimodal Imaging Laboratory (MMIL) now the Center for Multimodal Imaging and Genetics (CMIG),
including: Don Hagler, Anders Dale, Vijay Venkatraman, Dominic Holland, Nate White, Cooper Roddey, Alain
Koyama, Jason Sherfey, Rajan Patel, Ben Cippolini, Hauke Bartsch, Feng Xue, Octavio Ruiz De Leon, Sean
Hatton, and M. Daniela Cornejo.
The MMPS docker image is a portable version of the MMPS pipeline. This pipeline has scripts, binaries and
compiled matlab scripts that are needed for MRI data processing. The ABCD shared tabulated data and
miniproc data are generated by using this pipeline.
Packages shipped with this pipeline:
```
FSL, Ver:5.0.2.2-centos6_64
Freesurfer, Ver: 711
AFNI, Ver: 2010_10_19_1028
MMPS, Ver: 251
Dcm2niix, Ver: trunk
dtitk, Ver: 2.3.1-Linux-x86_64
gosu, Ver: 1.11
Matlab Compiler Runtime, Ver: v84
dcmtk, Ver: 3.6.0
Some scripts from SPM5b
```
## Prerequisites

- Host OS. This docker container has been tested under Centos 7.4.1708 and MacOS (Intel CPU). It has not been tested under Microsoft Windows.
- Memory and storage for docker
  - At least 6GB memory is required to run all processing steps, 12GB is recommended.
  - On Mac, 64GB disk image size is recommended (the uncompressed MMPS docker is approximately 22GB). The build will not produce a working image on M1/M2 chips even if the platform amd64 is selected. At least Matlab does not work on the M1/M2 chips currently and will stop with a clock-reading error.
- FreeSurfer license. A personal FreeSurfer license needs to be obtained from <https://surfer.nmr.mgh.harvard.edu/registration.html>. Please note, version of FreeSurfer is 530.

## Recommendations
Use ABCD protocol, simple classify
bval/bvecs from header in Philips/Seimens, from file for GE

## Installation
1. download these three necessary files:
   - abcd dockerfile and script (Dockerfile and abcddocker_installer.sh)
   - mmps_home.tar.gz
   - run_abcd_docker.sh

2. build docker image:
  ```
  build -t abcd .
  ```
  This may take at least half an hour depends on your network bandwidth.
3. In a temporary location, unpack the mmps_home.tar.gz file that contains the necessary scripts and
data that will be mounted to the docker container’s /home/MMPS directory:
   - .cshrc: shell enviorment configuration file that defines the version of several necessary
software packages.
   - bin/: binary folder contains necessary scripts, which are explained in run_abcd_docker.sh
   - ProjInfo/MMIL_ProjInfo.csv: This is the project setup configuration file. There is an example
setup for project: DAL_ABCD. This file defines location of necessary processing
directories and some necessary parameters.
   - ProjInfo/$ProjID/${ProjID}_*_ProcSteps.csv: these are processing steps files that defines
parameters needed for each processing step. Each step is explained in run_abcd_docker.sh
   - ProjInfo/network_*: containers parcellation maps
4. To configure a project, modify the run_abcd_docker.sh script. Please input appropriate values for
these following variables:
   - ProjID: (your project id, example: DAL_ABCD)
   - FSLic: (where you saved the obtained FreeSurfer license from step 1. example: `pwd`/.license
   - HomeRoot: location that the mmps_home.tar.gz is extracted to from step 1, such as the host download directory. Example: /Users/dsmith/Download/mmps_home
   - RawDataRoot: location where the fast-track tgz files are, this has to be a path inside the docker container. Example: /home/MMPS/data/fast-track
   - You may also adjust the processing step configuration files as required.

## Processing steps
Please also check notes inside $HomeRoot/bin/run_preparedata.sh:
1. Data preparation:
The $HomeRoot/bin/run_preparedata.sh will create the necessary directories, unpack the compressed tgz
files and move them into appropriate locations.
2. Initial data summary:
The $HomeRoot/bin/run_incoming_report.sh will summarize all unpacked imaging series based on those
json files. It will also save the summary to /home/MMPS/MetaData/$ProjID/${ProjID}_incoming_info.csv
This step is optional but recommended
3. Preprocessing:
In this step, DICOM data will first be converted into mgz format, then different correction processes will run for
different modality (e.g. dMRI files will be corrected for motion/bias field/B0/Eddy current etc.)
This will run preprocessing steps based on:
infix_list in $HomeRoot/bin/run_ABCD_pre.sh
and the proc step files for each preprocessing step.
For example, there are four preprocessing steps in run_ABCD_pre.sh now, which are: pc, proc, fsurf, and
proc_dMRI. Their associated proc step file are:
```
/home/MMPS/ProjInfo/$ProjID/${ProjID}_pc_ProcSteps.csv
/home/MMPS/ProjInfo/$ProjID/${ProjID}_proc_ProcSteps.csv
/home/MMPS/ProjInfo/$ProjID/${ProjID}_freesurfer_ProcSteps.csv
/home/MMPS/ProjInfo/$ProjID/${ProjID}_proc_dMRI_ProcSteps.csv
```
Those proc step files contains necessary parameters for processing. You may change them for your own
need but default is recommended. Here are some description for those preprocessing steps:
- pc: protocol compliance check, this is necessary for fMRI analysis
- proc: DICOM to mgz conversion and corrections (motion/bias field/eddy current etc.)
- freesurfer: freesurfer surface reconstruction
- proc_dMRI: specific DTI data processing
4. Protocol compliance check summary:
The run_summarizePC.sh will summarize result of the pc step and save the summary to
/home/MMPS/MetaData/$ProjID/${ProjID}_pcinfo.csv. This step has to be run after pc. This summary will be
used by the fMRI data analysis
5. Postprocessing:
This will run postprocessing steps based on:
infix_list in /home/MMPS/bin/run_ABCD_post.sh
and the proc step files for each step.
For example, there are 16 postprocessing steps in run_ABCD_post.sh now, which are:

analysis steps:
```
analyze_sMRI
analyze_dMRI
analyze_DTI_full
analyze_behav
analyze_rsBOLD
analyze_taskBOLD
```
summary steps:
```
summarize_DTI
summarize_DTI_full
summarize_RSI
summarize_MRI
summarize_MRI_info
summarize_rsBOLD_aparc2_networks
summarize_rsBOLD_aparc2_subcort
summarize_rsBOLD_aparc2_var
summarize_taskBOLD
summarize_behav
```
They also have associated proc step file in /home/MMPS/ProjInfo/$ProjID/. Those proc step files contains
necessary parameters for processing. You may change them for your own need but default is recommended.
If succeeded, you may find summarized results in
/home/MMPS/MetaData/$ProjID/ROI_Summaries

## Creating your own project
You may also follow steps below to create your own project(s):
Let’s say, you want to create a new project called ABCD_NEW (case sensitive). And you did the following:
1. unpacked mmps_home.tar.gz to /path/to/mmps_home
2. Put fast-track tgzs under /path/to/mmps_home/data/fast-track
3. Put freesurfer license under /path/to/freesurfer/.license
Now, let’s first create a record in MMPS_ProjInfo.csv as below:
1. Create a new line, put ABCD_NEW for the ProjID column
2. Change name for the PI column unless you are at DAIC.
3. Change path value for columns below. Please remember, the paths are inside docker container not
on the host. If you want to specify paths out of /home/MMPS, you will need to mount it in the docker
container using -v option first. Here we suppose that you want to put all processing folders under
/home/MMPS/data/ABCD_NEW. Below, please find lists of column names of the ProjInfo file on the
left side and values accordingly on the right side.
```
incoming → /home/MMPS/data/ABCD_NEW/incoming
unpack → /home/MMPS/data/ABCD_NEW/unpack
pc → /home/MMPS/data/ABCD_NEW/pc
qc → /home/MMPS/data/ABCD_NEW/qc
orig → /home/MMPS/data/ABCD_NEW/orig
raw → /home/MMPS/data/ABCD_NEW/raw
proc → /home/MMPS/data/ABCD_NEW/proc
proc_dti → /home/MMPS/data/ABCD_NEW/proc_dti
proc_bold → /home/MMPS/data/ABCD_NEW/proc_bold
fsurf → /home/MMPS/data/ABCD_NEW/fsurf
fsico → /home/MMPS/data/ABCD_NEW/fsico
```
Please do not change values for other columns unless you know the meaning.
After that, let’s create a ProjInfo folder for project ABCD_NEW using command below:
```
cp -a /path/to/mmps_home/ProjInfo/DAL_ABCD /path/to/mmps_home/ProjInfo/ABCD_NEW
```
Then rename those DAL_ABCD_* files to ABCD_NEW_*, for example:
```
mv /path/to/mmps_home/ProjInfo/ABCD_NEW/DAL_ABCD_Series_Classify.csv /path/to/mmps_home/ProjInfo/ABCD_NEW/ABCD_NEW_Series_Classify.csv
```
Next, you may change parameter inside those proc step files for your own need.
Thus, we finished making project info record and proc step files. Now, let’s modify parameters in the
run_abcd_docker.sh as below:
- ProjID=ABCD_NEW
- FSLic=/path/to/freesurfer/.license
- HomeRoot=/path/to/mmps_home
- RawDataRoot=/home/MMPS/data/fast-track
You may also change processing steps inside the run_abcd_docker.sh script for your own need. You may
even make your own script and put it in /path/to/mmps_home/bin and change -c parameter of docker to
execute it.
Finally, let’s execute the run_abcd_docker.sh script and sit back. It may run for hours (or even longer)
depending on the processing steps you choose and the size of the dataset. Don’t forget to put on your power
adapter if you are running on laptop.

## Building this container

In order to build this container some files not shared on this repository are required. These files are:

- MMPS_254.tar (an archive of the /usr/pubsw/packages/MMPS/MMPS_254 folder from San Diego)
- atlases.2020.10.14.tar (an archive of the /usr/pubsw/packages/MMPS/atlases/atlases.2020.10.14 folder from San Diego)

These files are referenced on the Dockerfile and are expected to be in the local directory. The image can be build with:

```{bash}
docker build --no-cache -t mmps_docker .
```

and run (for testing) with:

```{bash}
docker run --rm -it --entrypoint /bin/bash mmps_docker:latest
```
