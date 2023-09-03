#!/bin/csh

# setup python packages
if ( `hostname|grep "mmil-compute-6\|cluster6\|mmil-compute-7\|cluster7\|mmil-compute-8\|cluster8\|mmil-compute-9\|cluster9"|wc -l` > 0 ) then
  module load opt-python
  source /export/apps/python_env/bin/activate.csh
else if ( `hostname|grep "mmil-compute-5\|cluster5"|wc -l` > 0 ) then
  module load opt-python
  source /share/apps/python_env/bin/activate.csh
else if ( `hostname|grep "mmil-compute-4\|cluster4"|wc -l` > 0 ) then

else
  source /home/python36/.pyenv/versions/3.6.9/envs/processing369/bin/activate.csh
endif

