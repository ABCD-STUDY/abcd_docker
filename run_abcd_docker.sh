#!/usr/bin/env bash
#############################
#ABCD docker loader
#By Feng Xue @ UCSD 08/13/2019
#############################

############################################################################################
#Parameters needs action
# ProjID, shared with ProjInfo and Procsteps files.
# FSLic, /path/to/freesurfer license
# HomeRoot, where the mmps_home.tar.gz is unpacked to
# RawDataRoot, /path/to/fast_track_tgz
############################################################################################
ProjID=DAL_ABCD
FSLic=/usr/pubsw/packages/freesurfer/RH6-x86_64-R711/.license
HomeRoot=/space/syn09/1/data/MMILDB/xfgavin/docker/abcd_docker/mmps_home
############################################################################################

LOCAL_USER_ID=`id -u $USER`
#give a random UID if user is root
[ $LOCAL_USER_ID -eq 0 ] && LOCAL_USER_ID=1000
############################################################################################
#This is where you saved fast track tgzs.
#This has to be a path inside the docker container

RawDataRoot=/home/MMPS/data/fast-track
############################################################################################

[ ! -f $HomeRoot/.cshrc ] && echo "Error: file $HomeRoot/.cshrc does not exist, please check HomeRoot value" && exit -1
FSVer=`grep SetUpFreeSurfer $HomeRoot/.cshrc|awk '{print  $3}'`
PUBSH=`grep "setenv PUBSH" $HomeRoot/.cshrc|awk '{print  $3}'`
FSPath=$PUBSH/packages/freesurfer/RH4-x86_64-R$FSVer

############################################################################################
#STEP 1: data preparation
#The run_preparedata.sh will create needed dirs
#unpack tgzs and put them into appropriate dirs
############################################################################################

docker run --rm -it -e LOCAL_USER_ID=$LOCAL_USER_ID \
           -v $HomeRoot:/home/MMPS \
           -v $FSLic:$FSPath/.license \
           abcd /bin/csh -c "/home/MMPS/bin/run_preparedata.sh -p $ProjID -i $RawDataRoot"

############################################################################################
#STEP 2: initial data summary
#The run_incoming_report.sh will summarize all unpacked
#imaging series based on those json files. It will also
#save the summary to /home/MMPS/MetaData/$ProjID/${ProjID}_incoming_info.csv
#This step is optional but recommended
############################################################################################

docker run --rm -it -e LOCAL_USER_ID=$LOCAL_USER_ID \
           -v $HomeRoot:/home/MMPS \
           -v $FSLic:$FSPath/.license \
           abcd /bin/csh -c "/home/MMPS/bin/run_incoming_report.sh -p $ProjID"

############################################################################################
#STEP 3: preprocessing
#This will run preprocessing steps based on:
#  infix_list in /home/MMPS/bin/run_ABCD_pre.sh
#  and the proc step files for each preprocessing step.
#For example, there are four preprocessing steps in run_ABCD_pre.sh now
#Which are: pc, proc, fsurf, and proc_dMRI
#Their associated proc step file are
#  /home/MMPS/ProjInfo/$ProjID/${ProjID}_pc_ProcSteps.csv
#  /home/MMPS/ProjInfo/$ProjID/${ProjID}_proc_ProcSteps.csv
#  /home/MMPS/ProjInfo/$ProjID/${ProjID}_freesurfer_ProcSteps.csv
#  /home/MMPS/ProjInfo/$ProjID/${ProjID}_proc_dMRI_ProcSteps.csv
#Those proc step files contains necessary parameters for processing
#You may change them for your own need but default is recommended
#Here are some description for those preprocessing steps
#  pc: protocol compliance check, this is necessary for fMRI analysis
#  proc: DICOM to mgz conversion and corrections (motion/bias field/eddy current etc.)
#  fsurf: freesurfer surface reconstruction
#  proc_dMRI: specific DTI data processing
############################################################################################

docker run --rm -it -e LOCAL_USER_ID=$LOCAL_USER_ID \
           -v $HomeRoot:/home/MMPS \
           -v $FSLic:$FSPath/.license \
           abcd /bin/csh -c "/home/MMPS/bin/run_ABCD_pre.sh $ProjID"

############################################################################################
#STEP 4: protocol compliance check summary
#The run_summarizePC.sh will summarize result of the pc step and
#save the summary to /home/MMPS/MetaData/$ProjID/${ProjID}_pcinfo.csv
#This step has to be run after pc.
#This summary will be used by the fMRI data analysis
############################################################################################

docker run --rm -it -e LOCAL_USER_ID=$LOCAL_USER_ID \
           -v $HomeRoot:/home/MMPS \
           -v $FSLic:$FSPath/.license \
           abcd /bin/csh -c "/home/MMPS/bin/run_summarizePC.sh -p $ProjID"

#############################################################################################
#STEP 5: postprocessing
#This will run postprocessing steps based on:
#  infix_list in /home/MMPS/bin/run_ABCD_post.sh
#  and the proc step files for each step.
#For example, there are 16 postprocessing steps in run_ABCD_post.sh now
#Which are:
#  6 analysis steps:
#    analyze_sMRI analyze_dMRI analyze_DTI_full analyze_behav analyze_rsBOLD analyze_taskBOLD
#  10 summary steps:
#  summarize_DTI summarize_DTI_full summarize_MRI summarize_MRI_info summarize_RSI
#  summarize_rsBOLD_aparc2_networks summarize_rsBOLD_aparc2_subcort summarize_rsBOLD_aparc2_var
#  summarize_taskBOLD
#  summarize_behav
#They also have associated proc step file in /home/MMPS/ProjInfo/$ProjID/
#Those proc step files contains necessary parameters for processing
#You may change them for your own need but default is recommended
#If succeeded, you may find summarized results in 
# /home/MMPS/MetaData/$ProjID/ROI_Summaries 
############################################################################################

docker run --rm -it -e LOCAL_USER_ID=$LOCAL_USER_ID \
           -v $HomeRoot:/home/MMPS \
           -v $FSLic:$FSPath/.license \
           abcd /bin/csh -c "/home/MMPS/bin/run_ABCD_post.sh $ProjID"

############################################################################################
#You may change infix_list in run_ABCD_pre.sh and run_ABCD_post.sh to add/remove step(s).
#But please keep the order of following commands or the analysis may fail.
############################################################################################
