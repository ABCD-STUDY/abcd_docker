#!/bin/tcsh -f

################################################################################
#   Default MMIL SetUpCamino.csh file
#   Created 2018-02-21 Don Hagler
## todo:   Master Copy Stored at /usr/pubsw/scripts/SetUpCamino.csh
#
################################################################################

################################################################################
### Default pubsw location
###
### NOTE: This definition places the 'determination' of 'where' /usr/pubsw IS
###       into the hands of the machine maintainter. /usr/pubsw can be linked
###       the the shared storage location (/md7/1/pubsw) or locally.
###
setenv PUBSW /usr/pubsw

################################################################################
### Set Camino Environment

setenv JAVADIR /usr/java/latest
setenv CAMINODIR ${PUBSW}/packages/camino

# 10000 Mb = 10 Gb memory limit
setenv CAMINO_HEAP_SIZE 10000

# set paths for Camino
setenv PATH ${JAVADIR}/bin:$PATH
setenv PATH ${CAMINODIR}/bin:$PATH
setenv MANPATH ${CAMINODIR}/bin:$PATH

################################################################################
### Remove duplicates from path WITHOUT reording
set path=`echo $path | awk '{for(i=1;i<=NF;i++){if(!($i in a)){a[$i];printf s$i;s=" "}}}'`

